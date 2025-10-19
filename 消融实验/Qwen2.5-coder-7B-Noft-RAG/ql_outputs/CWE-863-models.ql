import python
import semmle.python.security.dataflow.PamAuthorizationQuery
import PamAuthorizationFlow::PathGraph
from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
    where PamAuthorizationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Incorrect authorization check performed."