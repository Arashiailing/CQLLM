/**
* @name CWE-863: Incorrect Authorization
*
@description The product performs an authorization check when an act
    or attempts to access a resource
    or perform an action, but it does not correctly perform the check.
*
@id py/views-cwe-863
*/
import python
import PamAuthorizationFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.PamAuthorizationQuery
from PamAuthorizationFlow::PathNode source, PamAuthorizationFlow::PathNode sink
    where PamAuthorizationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Incorrect authorization check performed."