import python
import semmle.python.security.dataflow.BufferOverreadQuery

/**
 * @name CWE-125: Out-of-bounds Read
 * @description The product reads data past the end, or before the beginning, of the intended buffer.
 * @id py/setup
 */

from BufferOverreadFlow::PathNode source, BufferOverreadFlow::PathNode sink
where BufferOverreadFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Out-of-bounds read detected at $@.", source.getNode()