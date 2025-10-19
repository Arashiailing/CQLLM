/**
 * @name Bad HTML filtering regexp
 * @description Matching HTML tags using regular expressions is hard to do right, and can easily lead to security issues.
 * @id py/openssl_privatekey_info
 */

import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import HeaderInjectionFlow::PathGraph

from HeaderInjectionFlow::PathNode source, HeaderInjectionFlow::PathNode sink
where HeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This HTTP header is constructed from a $@.", source.getNode(),  "user-provided value"