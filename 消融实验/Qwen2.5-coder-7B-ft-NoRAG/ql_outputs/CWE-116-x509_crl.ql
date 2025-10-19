/**
 * @name Bad HTML filtering regexp
 * @description Matching HTML tags using regular expressions is hard to do right, and can easily lead to security issues.
 * @id py/bad-html-filtering-regexp
 */

import python
import semmle.python.security.dataflow.BadHTMLFilterQuery

from BadHTMLFilterQuery::PathNode source, BadHTMLFilterQuery::PathNode sink
where BadHTMLFilterQuery::flowPath(source, sink)
select sink.getNode(), source, sink, "Bad HTML filtering regexp detected.", source.getNode(), "user-provided input"