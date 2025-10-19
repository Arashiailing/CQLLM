/**
 * @name Improper LDAP Authentication
 * @description LDAP bind operation lacks proper authentication mechanism
 * @kind problem
 * @problem.severity warning
 * @id py/improper-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-287
 */

// Import necessary modules for data flow analysis and LDAP concepts
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

/**
 * Predicate to detect LDAP bind operations that lack proper authentication.
 * This identifies cases where the password is either None, not provided, or an empty string.
 */
predicate isLdapAuthenticationFlawed(LdapBind ldapOperation) {
  // Check for None or missing password
  (
    DataFlow::localFlow(DataFlow::exprNode(any(None noneValue)), ldapOperation.getPassword()) or
    not exists(ldapOperation.getPassword())
  )
  // Check for empty string password
  or
  exists(StringLiteral emptyStr |
    emptyStr.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStr), ldapOperation.getPassword())
  )
}

// Query to identify all LDAP bind operations with authentication issues
from LdapBind ldapOperation
where isLdapAuthenticationFlawed(ldapOperation)
select ldapOperation, "The following LDAP bind operation is executed without authentication."