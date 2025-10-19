/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
*
@id py/basic_auth
*/
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow predicate authenticatesImproperly(BasicAuth basicAuth) { exists(Call authCall | authCall.getFunction().pointsTo(basicAuth)) }
from BasicAuth basicAuth, Call call
    where authenticatesImproperly(basicAuth)
    and call.getFunction().pointsTo(basicAuth)
    select call, "Basic authentication without proper proof of identity."