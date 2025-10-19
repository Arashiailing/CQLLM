@name Bad HTML filtering regexp
@id py/x509_crl
import python
private import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView
import codeql.regex.nfa.BadTagFilterQuery::Make<TreeView>
from HtmlMatchingRegExp regexp
select regexp, "Potential HTML tag filtering regex vulnerability"