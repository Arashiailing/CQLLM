/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
*
@id py/0004_auto_20200810_1111
*/
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow predicate authenticatesImproperly(LdapBind ldapBind) { exists(DataFlow::Local local | local.getSource().getKind() = DataFlow::SourceKind::CALL && local.getSource().getFunction().pointsTo(experimental.semmle.python.api.LdapConnection::bind) && local.getTarget() = ldapBind ) }
from LdapBind ldapBind
    where authenticatesImproperly(ldapBind)
    select ldapBind, "Improper LDAP authentication detected."