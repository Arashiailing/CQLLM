/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
*
@id py/serializers
*/
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow predicate authenticatesImproperly(LdapBind ldapBind) { ( ldapBind.getPassword().asExpr().isKind(ImmutableLiteral).booleanValue() = false
    or ldapBind.getUsername().asExpr().isKind(ImmutableLiteral).booleanValue() = false ) }
from LdapBind ldapBind
    where authenticatesImproperly(ldapBind)
    select ldapBind, "Improper authentication: User credentials are not properly verified."