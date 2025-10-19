/**
 * @name Improper LDAP Authentication
 * @description Detects LDAP bind operations lacking proper authentication credentials
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

/**
 * Identifies LDAP bind operations with inadequate authentication credentials.
 * Two scenarios are covered:
 * 1. Password parameter is either None, missing, or derived from a None literal
 * 2. Password parameter is derived from an empty string literal
 */
predicate hasImproperAuthentication(LdapBind ldapBinding) {
  // Scenario 1: Password is None or absent
  (
    exists(None noneValue |
      DataFlow::localFlow(DataFlow::exprNode(noneValue), ldapBinding.getPassword())
    )
    or
    not exists(ldapBinding.getPassword())
  )
  // Scenario 2: Password is an empty string
  or 
  exists(StringLiteral emptyStringLiteral |
    emptyStringLiteral.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStringLiteral), ldapBinding.getPassword())
  )
}

from LdapBind ldapBinding
where hasImproperAuthentication(ldapBinding)
select ldapBinding, "LDAP bind operation executed without proper authentication credentials."