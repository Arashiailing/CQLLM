/**
 * @name Hard-coded credentials
 * @description Credentials are hard coded in the source code of the application.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision medium
 * @id py/hardcoded-credentials
 * @tags security
 *       external/cwe/cwe-259
 *       external/cwe/cwe-321
 *       external/cwe/cwe-798
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.filters.Tests
private import semmle.python.dataflow.new.internal.DataFlowDispatch as DataFlowDispatch
private import semmle.python.dataflow.new.internal.Builtins::Builtins as Builtins
private import semmle.python.frameworks.data.ModelsAsData

// 定义字符比例阈值约束
bindingset[charToCount, maxFraction]

// 检查字符串中特定字符数量是否低于给定比例
predicate character_count_below_threshold(StringLiteral stringLiteral, string charToCount, float maxFraction) {
  exists(string textContent, int charCount |
    textContent = stringLiteral.getText() and // 获取字符串内容
    charCount = count(int i | textContent.charAt(i) = charToCount) // 计算目标字符出现次数
  |
    /* 允许单个字符 */
    charCount = 1 or // 只出现一次时满足条件
    charCount < textContent.length() * maxFraction // 出现次数低于文本长度乘以比例阈值
  )
}

// 检查名称是否可能属于反射元素（函数/类/模块/内置函数）
predicate is_potential_reflective_name(string nameStr) {
  any(Function func).getName() = nameStr or // 匹配函数名
  any(Class cls).getName() = nameStr or // 匹配类名
  any(Module mod).getName() = nameStr or // 匹配模块名
  exists(Builtins::likelyBuiltin(nameStr)) // 匹配内置函数名
}

// 计算字符串中的不同字符数量
int distinct_char_count(StringLiteral stringLiteral) { 
  result = count(string c | c = stringLiteral.getText().charAt(_)) 
}

// 检查是否为首字母大写的单词
predicate is_capitalized_word(StringLiteral stringLiteral) { 
  stringLiteral.getText().regexpMatch("[A-Z][a-z]+") 
}

// 检查是否为格式化字符串
predicate is_format_string(StringLiteral stringLiteral) { 
  stringLiteral.getText().matches("%{%}%") 
}

// 识别可能包含凭证信息的控制流节点
predicate contains_potential_credential(ControlFlowNode node) {
  /* 检查字符串字面量：长度适中且非标识符文本 */
  exists(StringLiteral stringLiteral | stringLiteral = node.getNode() |
    /* 至少10个字符 */
    stringLiteral.getText().length() > 9 and 
    /* 空格比例低于5% */
    character_count_below_threshold(stringLiteral, " ", 0.05) and 
    /* 下划线比例低于20% */
    character_count_below_threshold(stringLiteral, "_", 0.2) and 
    /* 检查字符多样性 */
    exists(int charVariety | charVariety = distinct_char_count(stringLiteral) |
      charVariety > 15 or // 高多样性
      charVariety * 3 > stringLiteral.getText().length() * 2 // 多样性阈值计算
    ) and
    not is_potential_reflective_name(stringLiteral.getText()) and // 排除反射名称
    not is_capitalized_word(stringLiteral) and // 排除首字母大写单词
    not is_format_string(stringLiteral) // 排除格式化字符串
  )
  or
  /* 检查大整数（超过32位） */
  exists(IntegerLiteral intLiteral | node.getNode() = intLiteral |
    not exists(intLiteral.getValue()) and // 无有效整数值
    /* 排除标志位或整数常量 */
    not intLiteral.getN().matches("%00%") 
  )
}

// 硬编码值源定义
class HardcodedValueSource extends DataFlow::Node {
  HardcodedValueSource() { contains_potential_credential(this.asCfgNode()) }
}

// 凭证接收器定义
class CredentialSink extends DataFlow::Node {
  CredentialSink() {
    exists(string sinkModel | sinkModel.matches("credentials-%") |
      // 匹配模型定义的凭证接收器（如密码/用户名）
      this = ModelOutput::getASinkNode(sinkModel).asSink()
    )
    or
    exists(string nameStr |
      nameStr.regexpMatch(get_credential_name_pattern()) and // 匹配凭证命名模式
      not nameStr.matches("%file") // 排除文件相关凭证
    |
      /* 关键字参数场景 */
      exists(DataFlowDispatch::ArgumentPosition argPos | argPos.isKeyword(nameStr) |
        this.(DataFlow::ArgumentNode).argumentOf(_, argPos)
      )
      or
      /* 关键字值场景 */
      exists(Keyword kw | kw.getArg() = nameStr and kw.getValue().getAFlowNode() = this.asCfgNode())
      or
      /* 比较操作场景 */
      exists(CompareNode compareNode, NameNode nameNode | 
        nameNode.getId() = nameStr and
        (
          compareNode.operands(this.asCfgNode(), any(Eq eq), nameNode) or
          compareNode.operands(nameNode, any(Eq eq), this.asCfgNode())
        )
      )
    )
  }
}

/**
 * 获取凭证变量名的正则表达式模式
 * 匹配密码、用户名、证书等凭证相关变量名
 */
private string get_credential_name_pattern() {
  result = "(?i).*pass(wd|word|code|phrase)(?!.*question).*" or // 密码短语（排除安全问题）
  result = "(?i).*(puid|username|userid).*" or // 用户标识
  result = "(?i).*(cert)(?!.*(format|name)).*" // 证书（排除格式/名称）
}

// 硬编码凭证数据流配置
private module HardcodedCredentialsConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof HardcodedValueSource }
  predicate isSink(DataFlow::Node sink) { sink instanceof CredentialSink }
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 数据流追踪模块
module HardcodedCredentialsFlow = TaintTracking::Global<HardcodedCredentialsConfig>;

import HardcodedCredentialsFlow::PathGraph

from 
  HardcodedCredentialsFlow::PathNode source, 
  HardcodedCredentialsFlow::PathNode sink
where
  HardcodedCredentialsFlow::flowPath(source, sink) and // 确认数据流路径
  not any(TestScope test).contains(source.getNode().asCfgNode().getNode()) // 排除测试代码
select 
  source.getNode(), 
  source, 
  sink, 
  "This hardcoded value is $@.", 
  sink.getNode(), 
  "used as credentials"