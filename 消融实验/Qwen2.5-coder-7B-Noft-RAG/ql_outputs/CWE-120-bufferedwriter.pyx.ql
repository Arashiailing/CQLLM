import python
import semmle.python.security.dataflow.BufferOverflowQuery
import BufferedWriterFlow::PathGraph
from BufferedWriterFlow::PathNode source, BufferedWriterFlow::PathNode sink
    where BufferedWriterFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Buffer copy without checking size of input", source.getNode(), "user-supplied data"