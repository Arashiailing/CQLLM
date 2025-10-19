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
 * Identifies LDAP bind operations with insecure authentication patterns
 * by detecting three vulnerable credential scenarios:
 * - Missing password parameter
 * - Password derived from None literal
 * - Password set to empty string literal
 */
predicate hasInsecureAuth(LdapBind ldapBindOp) {
  // Check for missing password parameter
  not exists(ldapBindOp.getPassword())
  or
  // Check for password originating from None literal
  exists(None noneLiteral |
    DataFlow::localFlow(DataFlow::exprNode(noneLiteral), ldapBindOp.getPassword())
  )
  or
  // Check for password set to empty string literal
  exists(StringLiteral emptyStringLiteral |
    emptyStringLiteral.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStringLiteral), ldapBindOp.getPassword())
  )
}

// Identify all LDAP bind operations with insecure authentication
from LdapBind ldapBindOp
where hasInsecureAuth(ldapBindOp)
select ldapBindOp, "The following LDAP bind operation is executed without authentication."