import python
import semmle.python.security.dataflow.SharedResourceFlow
import SharedResourceFlow::PathGraph

from SharedResourceFlow::PathNode source, SharedResourceFlow::PathNode sink
where SharedResourceFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Concurrent access to shared resource detected without proper synchronization."