/**
* @name CWE-863: Incorrect Authorization
*
@description The product performs an authorization check when an act
    or attempts to access a resource
    or perform an action, but it does not correctly perform the check.
*
@id py/incorrect-authz
*/
import python
import semmle.python.security.dataflow.AuthorizationQuery
from AuthorizationFlow::PathNode source, AuthorizationFlow::PathNode sink
    where AuthorizationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Incorrect authorization check at $@.", source.getNode()