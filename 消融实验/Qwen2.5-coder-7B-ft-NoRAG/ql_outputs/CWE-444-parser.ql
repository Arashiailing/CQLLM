/**
 * @name CWE-444: Inconsistent Interpretation of HTTP Requests ('HTTP Request/Response Smuggling')
 * @description nan
 * @id py/parser
 */

import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
where HttpHeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This HTTP request/response pair may be subject to smuggling.", source.getNode(), "user-provided value"