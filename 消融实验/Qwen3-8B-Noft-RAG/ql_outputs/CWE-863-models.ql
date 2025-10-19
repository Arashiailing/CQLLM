import python
import semmle.python.security.dataflow.PamAuthorizationQuery
import semmle.python.security.dataflow.PamAuthorizationFlow

from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
where PamAuthorizationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Incorrect authorization check detected", source.getNode(), "missing required authorization validation"