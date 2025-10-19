/**
 * @name Inefficient regular expression
 * @description A regular expression that requires exponential time to match certain inputs
 *              can be a performance bottleneck, and may be vulnerable to denial-of-service
 *              attacks.
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

// 导入正则表达式树视图模块，并命名为TreeView
private import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView
// 导入指数回溯检测模块，并生成相应的实例
import codeql.regex.nfa.ExponentialBackTracking::Make<TreeView>

// 从正则表达式树视图中获取正则表达式项、泵字符串、状态和前缀消息
from TreeView::RegExpTerm t, string pump, State s, string prefixMsg
where
  // 检查是否存在可能导致指数回溯的正则表达式结果
  hasReDoSResult(t, pump, s, prefixMsg) and
  // 排除详细模式的正则表达式（暂时）
  not t.getRegex().getAMode() = "VERBOSE"
select t,
  // 选择正则表达式项，并生成警告信息
  "This part of the regular expression may cause exponential backtracking on strings " + prefixMsg +
    "containing many repetitions of '" + pump + "'."
