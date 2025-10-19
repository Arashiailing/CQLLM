/**
* @name CWE-400: Uncontrolled Resource Consumption
*
@description The product does not properly control the allocation
    and maintenance of a limited resource.
*
@id py/emailservlet
*/
import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import HttpHeaderInjectionFlow::PathGraph
from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
    where HttpHeaderInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This HTTP header is constructed
from a $@.", source.getNode(), "user-provided value"