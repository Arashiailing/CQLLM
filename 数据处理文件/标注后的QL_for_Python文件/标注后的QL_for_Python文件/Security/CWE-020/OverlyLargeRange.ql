/**
 * @name Overly permissive regular expression range
 * @description Overly permissive regular expression ranges match a wider range of characters than intended.
 *              This may allow an attacker to bypass a filter or sanitizer.
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision high
 * @id py/overly-large-range
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

// 导入必要的模块和类
private import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView
import codeql.regex.OverlyLargeRangeQuery::Make<TreeView>

// 从正则表达式树视图中获取字符范围和原因
from TreeView::RegExpCharacterRange range, string reason
// 过滤条件：如果存在正则表达式问题，则选择该范围和原因
where problem(range, reason)
// 选择结果：返回可疑的字符范围以及描述信息
select range, "Suspicious character range that " + reason + "."
