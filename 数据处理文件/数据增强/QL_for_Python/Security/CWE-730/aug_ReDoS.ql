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

// 导入正则表达式树视图模块并重命名
private import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView
// 导入指数回溯检测模块并生成实例
import codeql.regex.nfa.ExponentialBackTracking::Make<TreeView>

// 定义查询变量：正则表达式项、重复字符串、状态和前缀消息
from TreeView::RegExpTerm regexTerm, string repeatedString, State state, string prefixMessage
where
  // 检测是否存在导致指数回溯的正则表达式结果
  hasReDoSResult(regexTerm, repeatedString, state, prefixMessage) and
  // 排除详细模式（VERBOSE）的正则表达式
  not regexTerm.getRegex().getAMode() = "VERBOSE"
select regexTerm,
  // 生成包含风险描述的警告消息
  "正则表达式的这部分可能在包含大量'" + repeatedString + "'重复的字符串" + prefixMessage +
    "上导致指数级回溯问题。"