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

// 定义一个绑定集，用于存储字符和分数的映射关系
bindingset[char, fraction]

// 判断字符串字面量中某个字符的数量是否少于给定比例
predicate fewer_characters_than(StringLiteral str, string char, float fraction) {
  exists(string text, int chars |
    text = str.getText() and // 获取字符串文本内容
    chars = count(int i | text.charAt(i) = char) // 计算指定字符的数量
  |
    /* Allow one character */
    chars = 1 or // 如果字符数量为1，则满足条件
    chars < text.length() * fraction // 如果字符数量小于文本长度乘以给定比例，则满足条件
  )
}

// 判断名称是否可能是反射名称
predicate possible_reflective_name(string name) {
  any(Function f).getName() = name // 检查是否有函数名匹配
  or
  any(Class c).getName() = name // 检查是否有类名匹配
  or
  any(Module m).getName() = name // 检查是否有模块名匹配
  or
  exists(Builtins::likelyBuiltin(name)) // 检查是否是内建函数名
}

// 计算字符串字面量中的字符数量
int char_count(StringLiteral str) { result = count(string c | c = str.getText().charAt(_)) }

// 判断字符串字面量是否是首字母大写的单词
predicate capitalized_word(StringLiteral str) { str.getText().regexpMatch("[A-Z][a-z]+") }

// 判断字符串字面量是否是格式化字符串
predicate format_string(StringLiteral str) { str.getText().matches("%{%}%") }

// 判断控制流节点是否可能是凭证信息
predicate maybeCredential(ControlFlowNode f) {
  /* A string that is not too short and unlikely to be text or an identifier. */
  exists(StringLiteral str | str = f.getNode() |
    /* At least 10 characters */
    str.getText().length() > 9 and // 字符串长度至少为10个字符
    /* Not too much whitespace */
    fewer_characters_than(str, " ", 0.05) and // 空格字符不超过总长度的5%
    /* or underscores */
    fewer_characters_than(str, "_", 0.2) and // 下划线字符不超过总长度的20%
    /* Not too repetitive */
    exists(int chars | chars = char_count(str) |
      chars > 15 or // 字符种类超过15种
      chars * 3 > str.getText().length() * 2 // 字符种类的三倍大于字符串长度的两倍
    ) and
    not possible_reflective_name(str.getText()) and // 不是反射名称
    not capitalized_word(str) and // 不是首字母大写的单词
    not format_string(str) // 不是格式化字符串
  )
  or
  /* Or, an integer with over 32 bits */
  exists(IntegerLiteral lit | f.getNode() = lit |
    not exists(lit.getValue()) and // 整数值不存在
    /* Not a set of flags or round number */
    not lit.getN().matches("%00%") // 不是一组标志或整数
  )
}

// 定义硬编码值源类，继承自数据流节点类
class HardcodedValueSource extends DataFlow::Node {
  HardcodedValueSource() { maybeCredential(this.asCfgNode()) } // 如果当前节点可能是凭证信息，则实例化该类
}

// 定义凭证接收器类，继承自数据流节点类
class CredentialSink extends DataFlow::Node {
  CredentialSink() {
    exists(string s | s.matches("credentials-%") |
      // 实际的接收器类型将是诸如 `credentials-password` 或 `credentials-username` 之类的内容
      this = ModelOutput::getASinkNode(s).asSink()
    )
    or
    exists(string name |
      name.regexpMatch(getACredentialRegex()) and // 匹配凭证正则表达式
      not name.matches("%file") // 排除文件类型的凭证
    |
      exists(DataFlowDispatch::ArgumentPosition pos | pos.isKeyword(name) |
        this.(DataFlow::ArgumentNode).argumentOf(_, pos) // 参数节点是关键字参数
      )
      or
      exists(Keyword k | k.getArg() = name and k.getValue().getAFlowNode() = this.asCfgNode()) // 关键字参数的值是当前节点
      or
      exists(CompareNode cmp, NameNode n | n.getId() = name |
        cmp.operands(this.asCfgNode(), any(Eq eq), n) // 比较操作符的操作数是当前节点和名称节点
        or
        cmp.operands(n, any(Eq eq), this.asCfgNode()) // 比较操作符的操作数是名称节点和当前节点
      )
    )
  }
}

/**
 * Gets a regular expression for matching names of locations (variables, parameters, keys) that
 * indicate the value being held is a credential.
 */
private string getACredentialRegex() {
  result = "(?i).*pass(wd|word|code|phrase)(?!.*question).*" or // 匹配包含密码、密码短语等的变量名，但不包括问题部分
  result = "(?i).*(puid|username|userid).*" or // 匹配包含用户名、用户ID等的变量名
  result = "(?i).*(cert)(?!.*(format|name)).*" // 匹配包含证书的变量名，但不包括格式或名称部分
}

// 定义硬编码凭证配置模块，实现数据流配置接口
private module HardcodedCredentialsConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof HardcodedValueSource } // 判断节点是否是硬编码值源

  predicate isSink(DataFlow::Node sink) { sink instanceof CredentialSink } // 判断节点是否是凭证接收器

  predicate observeDiffInformedIncrementalMode() { any() } // 观察差异通知增量模式
}

// 定义全局数据流跟踪模块，使用硬编码凭证配置模块进行配置
module HardcodedCredentialsFlow = TaintTracking::Global<HardcodedCredentialsConfig>;

import HardcodedCredentialsFlow::PathGraph // 导入路径图模块

from HardcodedCredentialsFlow::PathNode src, HardcodedCredentialsFlow::PathNode sink // 从路径图中选择源节点和目标节点
where
  HardcodedCredentialsFlow::flowPath(src, sink) and // 判断是否存在从源节点到目标节点的数据流路径
  not any(TestScope test).contains(src.getNode().asCfgNode().getNode()) // 排除测试范围内的节点
select src.getNode(), src, sink, "This hardcoded value is $@.", sink.getNode(), // 选择源节点、目标节点以及相关信息
  "used as credentials" // 输出硬编码值被用作凭证的信息
