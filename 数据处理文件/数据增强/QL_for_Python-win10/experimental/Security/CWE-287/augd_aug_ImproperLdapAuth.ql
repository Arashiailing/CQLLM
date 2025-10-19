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

// Import necessary modules for LDAP analysis and data flow tracking
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

/**
 * Identifies LDAP bind operations with insecure authentication by checking:
 * 1. Missing password parameter
 * 2. Password derived from None literal
 * 3. Password as empty string literal
 */
predicate hasInsecureAuth(LdapBind ldapBindOperation) {
  // Check for missing password parameter
  not exists(ldapBindOperation.getPassword())
  or
  // Check password derived from None literal
  exists(None noneLiteral |
    DataFlow::localFlow(DataFlow::exprNode(noneLiteral), ldapBindOperation.getPassword())
  )
  or
  // Check password as empty string literal
  exists(StringLiteral emptyStringLiteral |
    emptyStringLiteral.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStringLiteral), ldapBindOperation.getPassword())
  )
}

// Identify all LDAP bind operations with insecure authentication
from LdapBind ldapBindOperation
where hasInsecureAuth(ldapBindOperation)
select ldapBindOperation, "The following LDAP bind operation is executed without authentication."