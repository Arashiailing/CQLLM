import python
private import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView
import codeql.regex.nfa.BadTagFilterQuery::Make<TreeView>

from HtmlMatchingRegExp regexp, string msg
where msg = min(string m | isBadRegexpFilter(regexp, m) | m order by m.length())
select regexp, msg