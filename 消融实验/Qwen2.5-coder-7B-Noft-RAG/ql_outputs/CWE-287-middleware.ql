/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
*
@id py/middleware
*/
import python
import semmle.python.security.dataflow.PamAuthorizationQuery
from PathNode source, PathNode sink
    where PamAuthorizationQuery::flowPath(source, sink)
    select sink.getNode(), source, sink, "Improper authentication detected."