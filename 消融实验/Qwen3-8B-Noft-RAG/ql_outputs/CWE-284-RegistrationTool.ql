import python
import semmle.python.security.dataflow.AccessControlQuery

from AccessControlFlow::PathNode source, AccessControlFlow::PathNode sink
where AccessControlFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper access control allows unauthorized access.", source.getNode(), "unauthorized resource"