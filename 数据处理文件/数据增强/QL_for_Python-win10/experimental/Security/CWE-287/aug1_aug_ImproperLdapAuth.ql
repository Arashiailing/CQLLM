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
 * Identifies LDAP bind operations with authentication weaknesses by checking:
 * 1. Absence of password parameter
 * 2. Password derived from None literal
 * 3. Password using empty string literal
 */
predicate hasInsecureAuth(LdapBind ldapBindOp) {
  // Check for missing password parameter
  not exists(ldapBindOp.getPassword())
  or
  // Check for None literal as password source
  exists(None noneLiteral |
    DataFlow::localFlow(DataFlow::exprNode(noneLiteral), ldapBindOp.getPassword())
  )
  or
  // Check for empty string literal as password
  exists(StringLiteral emptyStringLiteral |
    emptyStringLiteral.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStringLiteral), ldapBindOp.getPassword())
  )
}

// Detect all LDAP bind operations exhibiting insecure authentication patterns
from LdapBind ldapBindOp
where hasInsecureAuth(ldapBindOp)
select ldapBindOp, "The following LDAP bind operation is executed without authentication."