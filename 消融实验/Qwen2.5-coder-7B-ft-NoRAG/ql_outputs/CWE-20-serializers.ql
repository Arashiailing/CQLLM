import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery

from PathNode source, PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe deserialization depends on a $@.", source.getNode(), "user-provided value"