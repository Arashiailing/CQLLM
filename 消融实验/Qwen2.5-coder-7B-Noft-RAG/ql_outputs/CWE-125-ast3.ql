/**
* @name CWE-125: Out-of-bounds Read
*
@description The product reads data past the end,
    or before the beginning, of the intended buffer.
*
@id py/ast3
*/
import python
from DataFlow::PathNode source, DataFlow::PathNode sink
    where DataFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Out-of-bounds read detected."