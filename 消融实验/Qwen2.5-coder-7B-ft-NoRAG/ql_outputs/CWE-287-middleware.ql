/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @id py/middleware
 */

import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

predicate improperAuthentication(LdapBind ldapBind) {
  (ldapBind.getPrincipal() instanceof UserProvidedValue or ldapBind.getCredential() instanceof UserProvidedValue)
}

from LdapBind ldapBind
where improperAuthentication(ldapBind)
select ldapBind, "Improper LDAP authentication detected."