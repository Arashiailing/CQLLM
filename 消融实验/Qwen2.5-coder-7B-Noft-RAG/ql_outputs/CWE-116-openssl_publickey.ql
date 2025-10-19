/**
* @name Bad HTML filtering regexp
*
@description Matching HTML tags using regular expressions is hard to do right,
    and can easily lead to security issues.
*
@id py/bad-tag-filter
*/
import python
import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView
import codeql.regex.nfa.BadTagFilterQuery::Make<TreeView>
from HtmlMatchingRegExp regexp, string msg
    where msg = min(string m | isBadRegexpFilter(regexp, m) | m order by m.length(), m)
    select regexp, msg