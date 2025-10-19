/**
* @name CWE-444: Inconsistent Interpretation of HTTP Requests ('HTTP Request/Response Smuggling')
*
@id py/parser
*/
import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import HttpHeaderInjectionFlow::PathGraph
from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
    where HttpHeaderInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This HTTP header is constructed
from a $@.", source.getNode(), "user-provided value"