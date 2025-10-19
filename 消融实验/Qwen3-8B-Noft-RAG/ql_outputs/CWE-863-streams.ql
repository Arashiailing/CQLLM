/**
 * @name CWE-863: Incorrect Authorization
 * @id py/streams
 */
import python
import semmle.python.security.dataflow.AuthorizationCheckQuery
import semmle.python.security.dataflow.AuthorizationCheckFlow

from AuthorizationCheckFlow::PathNode source, AuthorizationCheckFlow::PathNode sink
where AuthorizationCheckFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Authorization check missing for this operation", source.getNode()