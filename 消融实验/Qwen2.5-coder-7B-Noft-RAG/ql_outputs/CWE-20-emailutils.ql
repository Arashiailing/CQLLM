/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does * not validate
    or incorrectly validates that the input has the * properties that are required to process the data safely
    and * correctly.
*
@id py/emailutils
*/
import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
    where HttpHeaderInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "HTTP header is constructed
from a $@.", source.getNode(), "user-provided value"