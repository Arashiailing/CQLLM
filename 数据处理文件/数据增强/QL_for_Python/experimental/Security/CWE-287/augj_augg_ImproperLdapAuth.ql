/**
 * @name Improper LDAP Authentication
 * @description Detects LDAP bind operations lacking proper authentication,
 *              potentially enabling unauthorized directory service access.
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
 * Identifies LDAP bind operations with authentication deficiencies.
 * Checks for two scenarios: missing/None credentials or empty passwords.
 */
predicate isImproperLdapAuth(LdapBind ldapBindOp) {
  // Scenario 1: Credentials are either None or completely absent
  (
    exists(None noneVal |
      DataFlow::localFlow(DataFlow::exprNode(noneVal), ldapBindOp.getPassword())
    )
    or
    not exists(ldapBindOp.getPassword())
  )
  // Scenario 2: Credentials consist of an empty string
  or
  exists(StringLiteral emptyStrVal |
    emptyStrVal.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStrVal), ldapBindOp.getPassword())
  )
}

from LdapBind ldapBindOp
where isImproperLdapAuth(ldapBindOp)
select ldapBindOp, "The following LDAP bind operation is executed without authentication."