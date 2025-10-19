/**
* @name CWE-287: Improper Authentication
*
@description When an act
    or claims to have a given identity, the product does not prove
    or insufficiently proves that the claim is correct.
* @kind problem
* @problem.severity warning
*
@id py/crypto_gnupg
*/
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow predicate authenticatesImproperly(LdapBind ldapBind) { (exists(Call call | call.getFunc().pointsTo(Value::siteQuitter("ldap_bind"))
    and call.getArgs()[0] = ldapBind.getUser()
    and call.getArgs()[1] = ldapBind.getPassword() )
    or not ldapBind.hasPassword()) }
from LdapBind ldapBind
    where authenticatesImproperly(ldapBind)
    select ldapBind, "Improper LDAP authentication detected."