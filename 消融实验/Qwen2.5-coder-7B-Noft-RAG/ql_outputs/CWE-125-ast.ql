/**
* @name CWE-125: Out-of-bounds Read
*
@description The product reads data past the end,
    or before the beginning, of the intended buffer.
*
@id py/ast
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Out-of-bounds read detected at $@.", source.getNode()