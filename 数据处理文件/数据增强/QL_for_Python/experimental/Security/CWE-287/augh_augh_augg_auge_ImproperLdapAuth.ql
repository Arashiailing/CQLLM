/**
 * @name Improper LDAP Authentication
 * @description Identifies LDAP bind operations lacking proper authentication mechanisms
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
 * Detects LDAP bind operations with authentication deficiencies:
 * - Absence of password parameter
 * - Explicitly set to None value
 * - Configured with empty string
 */
predicate hasImproperAuthentication(LdapBind ldapBind) {
  // Scenario 1: Password parameter not provided
  not exists(ldapBind.getPassword())
  or
  // Scenario 2: Password explicitly assigned None
  exists(None noneValue |
    DataFlow::localFlow(DataFlow::exprNode(noneValue), ldapBind.getPassword())
  )
  or
  // Scenario 3: Password configured as empty string
  exists(StringLiteral emptyStr |
    emptyStr.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStr), ldapBind.getPassword())
  )
}

from LdapBind ldapBind
where hasImproperAuthentication(ldapBind)
select ldapBind, "The following LDAP bind operation is executed without authentication."