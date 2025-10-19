import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery

from ServerSideRequestForgeryQuery::PathNode source, ServerSideRequestForgeryQuery::PathNode sink
where ServerSideRequestForgeryQuery::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation leads to Server-Side Request Forgery."