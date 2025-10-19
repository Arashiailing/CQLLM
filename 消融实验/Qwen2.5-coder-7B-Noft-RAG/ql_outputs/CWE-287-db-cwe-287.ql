/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
*
@id py/db-cwe-287
*/
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow predicate authenticatesImproperly(LdapBind ldapBind) { ( exists(Call call | call.getFunc().pointsTo(ldapBind)
    and call.getCalleeArgument(0).isNonEmpty() ) ) }
from LdapBind ldapBind
    where authenticatesImproperly(ldapBind)
    select ldapBind, "Improper LDAP Authentication detected."