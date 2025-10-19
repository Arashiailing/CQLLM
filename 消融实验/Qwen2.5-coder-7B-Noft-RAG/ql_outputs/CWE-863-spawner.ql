/**
* @name CWE-863: Incorrect Authorization
*
@description The product performs an authorization check when an act
    or attempts to access a resource
    or perform an action, but it does not correctly perform the check.
*
@id py/spawner
*/
import python
import semmle.python.security.dataflow.PamAuthorizationQuery
import PamAuthorizationFlow::PathGraph
from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
    where PamAuthorizationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Incorrect authorization check performed."