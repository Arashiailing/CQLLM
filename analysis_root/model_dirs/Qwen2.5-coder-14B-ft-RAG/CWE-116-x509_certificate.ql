/**
* @name Bad HTML filtering regexp
* @description Matching HTML tags using regular expressions is hard to do right, and can easily lead to security issues.
* @kind problem
* @problem.severity warning
* @security-severity 7.8
* @precision high
* @id py/bad-tag-filter
* @tags correctness
*       security
*       external/cwe/cwe-116
*       external/cwe/cwe-020
*       external/cwe/cwe-185
*       external/cwe/cwe-186
*/

// 导入正则表达式树视图类，并将其重命名为TreeView
private import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView

// 从codeql.regex.nfa模块中导入BadTagFilterQuery类的Make方法，并指定其模板参数为TreeView
import codeql.regex.nfa.BadTagFilterQuery::Make<TreeView>

// 从HtmlMatchingRegExp和字符串msg中进行查询
from HtmlMatchingRegExp regexp, string msg

// 条件：msg是满足isBadRegexpFilter(regexp, m)条件的最小字符串（按长度排序），如果有多个，我们任意选择最短的一个
where msg = min(string m | isBadRegexpFilter(regexp, m) | m order by m.length(), m)

// 选择要返回的字段：regexp和msg
select regexp, msg