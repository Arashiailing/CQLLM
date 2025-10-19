/**
* @name CWE-125: Out-of-bounds Read
*
@description The product reads data past the end,
    or before the beginning, of the intended buffer.
*
@id py/asdl_c
*/
import python
import semmle.python.security.dataflow.CodeInjectionQuery
from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
    where CodeInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Out-of-bounds read due to a $@.", source.getNode(), "user-provided value"