/**
 * @name 低效正则表达式检测
 * @description 某些正则表达式在匹配特定输入时需要指数级时间，
 *              这可能成为性能瓶颈，并易受拒绝服务攻击。
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/redos
 * @tags security
 *       external/cwe/cwe-1333
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */

// 导入正则表达式树视图模块并重命名为视图模块
private import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView
// 导入指数回溯检测模块并创建实例
import codeql.regex.nfa.ExponentialBackTracking::Make<TreeView>

// 定义查询变量：正则表达式模式项、重复字符序列、NFA状态和上下文描述
from TreeView::RegExpTerm patternTerm, string repeatedCharSequence, State nfaState, string contextDescription
where
  // 检查是否存在导致指数回溯的正则表达式匹配结果
  hasReDoSResult(patternTerm, repeatedCharSequence, nfaState, contextDescription) and
  // 排除使用详细模式(VERBOSE)的正则表达式，因为它们通常更易于理解和维护
  not patternTerm.getRegex().getAMode() = "VERBOSE"
select patternTerm,
  // 构建警告消息，描述潜在的性能风险
  "正则表达式的这部分可能在包含大量'" + repeatedCharSequence + "'重复的字符串" + contextDescription +
    "上导致指数级回溯问题。"