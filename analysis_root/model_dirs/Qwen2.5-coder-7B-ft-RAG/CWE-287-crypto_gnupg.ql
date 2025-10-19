/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @kind problem
 * @problem.severity warning
 * @id py/improper-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-287
 */

import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

// Predicate function to check if LDAP bind operation is performed improperly
predicate authenticatesImproperly(LdapBind ldapBind) {
  // Condition 1: Local flow from None to password indicates improper authentication attempt
  exists(LocalFlow::PathNode source, LocalFlow::PathNode sink |
    LdapBind::localPasswordFlow(ldapBind, source, sink)
  )
  or
  // Condition 2: Password attribute of LDAP bind operation is null
  ldapBind.getPassword().isNull()
}

// Main query to detect improper LDAP authentication
from LdapBind ldapBind
where authenticatesImproperly(ldapBind)
select ldapBind,
  "LDAP binds with client-supplied passwords are vulnerable to replay attacks."