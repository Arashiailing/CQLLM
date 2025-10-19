import python
import semmle.python.security.dataflow.BufferOverflowQuery
import BufferedWriterFlow::PathGraph

from BufferedWriterFlow::PathNode source, BufferedWriterFlow::PathNode sink
where BufferedWriterFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Buffer overflow detected due to copying user-supplied input to an output buffer without checking the size."