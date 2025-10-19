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
 * Identifies LDAP bind operations with insecure authentication by detecting:
 * 1. Absence of password parameter
 * 2. Password derived from None literal
 * 3. Password as empty string literal
 */
predicate hasInsecureAuth(LdapBind ldapBindOp) {
  // Detect missing password parameter
  not exists(ldapBindOp.getPassword())
  or
  // Detect None literal used as password
  exists(None noneLiteral |
    DataFlow::localFlow(DataFlow::exprNode(noneLiteral), ldapBindOp.getPassword())
  )
  or
  // Detect empty string literal used as password
  exists(StringLiteral emptyStrLiteral |
    emptyStrLiteral.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStrLiteral), ldapBindOp.getPassword())
  )
}

// Identify all LDAP bind operations with insecure authentication
from LdapBind ldapBindOp
where hasInsecureAuth(ldapBindOp)
select ldapBindOp, "The following LDAP bind operation is executed without authentication."