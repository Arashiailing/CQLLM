/**
* @name Bad HTML filtering regexp
*
@description Matching HTML tags using regular expressions is hard to do right,
    and can easily lead to security issues.
*
@id py/openssl_privatekey_info
*/
import python
import semmle.python.security.dataflow.BadTagFilterQuery
from BadTagFilterQuery::PathNode source, BadTagFilterQuery::PathNode sink
    where BadTagFilterQuery::flowPath(source, sink)
    select sink.getNode(), source, sink, "Bad HTML filtering regexp detected."