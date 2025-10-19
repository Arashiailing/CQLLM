/**
* @name CWE-125: Out-of-bounds Read
*
@id py/setup
*/
import python
import semmle.python.security.dataflow.BufferOverreadQuery
from BufferOverreadFlow::PathNode source, BufferOverreadFlow::PathNode sink
    where BufferOverreadFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Out-of-bounds read detected at $@.", source.getNode()