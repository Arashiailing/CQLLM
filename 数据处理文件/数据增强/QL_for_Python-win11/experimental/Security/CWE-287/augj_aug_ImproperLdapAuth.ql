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
 * 3. Password set to empty string literal
 */
predicate hasInsecureAuth(LdapBind ldapOperation) {
  // Check for missing password parameter
  not exists(ldapOperation.getPassword())
  or
  // Check for None literal as password source
  exists(None noneLiteral |
    DataFlow::localFlow(DataFlow::exprNode(noneLiteral), ldapOperation.getPassword())
  )
  or
  // Check for empty string literal as password
  exists(StringLiteral emptyString |
    emptyString.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyString), ldapOperation.getPassword())
  )
}

// Identify all LDAP bind operations with insecure authentication
from LdapBind ldapOperation
where hasInsecureAuth(ldapOperation)
select ldapOperation, "The following LDAP bind operation is executed without authentication."