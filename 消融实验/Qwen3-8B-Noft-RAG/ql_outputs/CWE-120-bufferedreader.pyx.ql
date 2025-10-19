import python
import semmle.python.security.dataflow.BufferCopyWithoutSizeCheckQuery
import BufferCopyWithoutSizeCheckFlow::PathGraph

from BufferCopyWithoutSizeCheckFlow::PathNode source, BufferCopyWithoutSizeCheckFlow::PathNode sink
where BufferCopyWithoutSizeCheckFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Buffer copy without checking input size from $@.", source.getNode(), "untrusted data"