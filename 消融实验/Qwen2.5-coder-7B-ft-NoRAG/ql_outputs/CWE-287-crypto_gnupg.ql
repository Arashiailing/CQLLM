/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @id py/crypto_gnupg
 */

import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

predicate authenticatesImproperly(LdapBind ldapBind) {
  // If there is any local data flow from any None value to the password of ldapBind,
  // or ldapBind does not set a password, then return true
  (exists(Call c | c.getArg(1) = ldapBind.getPassword()) and c.getCallee().getName() = "None") or
  not exists(ldapBind.getPassword())
}

from LdapBind ldapBind
where authenticatesImproperly(ldapBind)
select ldapBind, "Improper LDAP authentication detected."