/**
* @name CWE-120: Buffer Copy without Checking Size of Input ('Classic Buffer Overflow')
*
@description The product copies an input buffer to an output buffer without verifying that the size of the input buffer is less than the size of the output buffer.
*
@id py/bufferedreader.pyx
*/
import python
import semmle.python.security.dataflow.BufferOverflowQuery
from BufferOverflowFlow::PathNode source, BufferOverflowFlow::PathNode sink
    where BufferOverflowFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Buffer copy without checking size of input", source.getNode()