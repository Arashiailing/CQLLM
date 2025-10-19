/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @id py/db-cwe-287
 */

import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

predicate authenticatesImproperly(LdapBind ldapBind) {
  (
    exists(Call c | c.getTarget() = ldapBind.getPassword() and c.getCallee() = Value::site("input"))
    or
    ldapBind.getPassword().(Expression).getKind()!= ExpressionKind.Variable
  )
}

from LdapBind ldapBind
where authenticatesImproperly(ldapBind)
select ldapBind, "Improper LDAP Authentication", "Potential LDAP injection risk."