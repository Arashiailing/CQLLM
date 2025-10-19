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
 * Identifies LDAP bind operations with insecure authentication by checking:
 * - Missing password parameter
 * - Password set to None literal
 * - Password set to empty string literal
 */
predicate hasInsecureAuth(LdapBind ldapBindOperation) {
  // Case 1: Password parameter is missing
  not exists(ldapBindOperation.getPassword())
  or
  // Case 2: Password is None literal
  exists(None noneLiteral |
    DataFlow::localFlow(DataFlow::exprNode(noneLiteral), ldapBindOperation.getPassword())
  )
  or
  // Case 3: Password is empty string literal
  exists(StringLiteral emptyStringLiteral |
    emptyStringLiteral.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStringLiteral), ldapBindOperation.getPassword())
  )
}

from LdapBind ldapBindOperation
where hasInsecureAuth(ldapBindOperation)
select ldapBindOperation, "The following LDAP bind operation is executed without authentication."