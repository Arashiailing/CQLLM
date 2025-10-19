/**
 * @name Improper LDAP Authentication
 * @description Detects LDAP bind operations that lack proper authentication
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
 * Identifies LDAP bind operations with improper authentication:
 * - Missing password parameter
 * - Password explicitly set to None
 * - Password set to empty string
 */
predicate hasImproperAuthentication(LdapBind ldapBind) {
  // Case 1: Password parameter is missing
  not exists(ldapBind.getPassword())
  or
  // Case 2: Password parameter is explicitly None
  exists(None noneLiteral |
    DataFlow::localFlow(DataFlow::exprNode(noneLiteral), ldapBind.getPassword())
  )
  or
  // Case 3: Password parameter is empty string
  exists(StringLiteral emptyStringLiteral |
    emptyStringLiteral.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStringLiteral), ldapBind.getPassword())
  )
}

from LdapBind ldapBind
where hasImproperAuthentication(ldapBind)
select ldapBind, "The following LDAP bind operation is executed without authentication."