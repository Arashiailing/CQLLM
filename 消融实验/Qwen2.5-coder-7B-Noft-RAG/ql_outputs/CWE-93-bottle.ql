/**
* @name CWE-93: Improper Neutralization of CRLF Sequences ('CRLF Injection')
*
@id py/bottle
*/
import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import HttpHeaderInjectionFlow::PathGraph
from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
    where HttpHeaderInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This HTTP header is constructed
from a $@.", source.getNode(), "user-provided value"