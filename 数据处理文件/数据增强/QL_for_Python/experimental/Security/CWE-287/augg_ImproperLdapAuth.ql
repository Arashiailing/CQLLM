/**
 * @name Improper LDAP Authentication
 * @description Detects LDAP bind operations that are executed without proper authentication,
 *              which could allow unauthorized access to directory services.
 * @kind problem
 * @problem.severity warning
 * @id py/improper-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-287
 */

// Import statements for precise analysis
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

// Predicate to identify LDAP bind operations with improper authentication
predicate hasImproperAuthentication(LdapBind ldapBinding) {
  // Check for authentication issues in LDAP bind operations
  (
    // Scenario 1: Password is explicitly set to None or no password is provided
    (
      exists(None noneLiteral |
        DataFlow::localFlow(DataFlow::exprNode(noneLiteral), ldapBinding.getPassword())
      )
      or
      not exists(ldapBinding.getPassword())
    )
    // Scenario 2: Password is an empty string
    or
    exists(StringLiteral emptyStrLiteral |
      emptyStrLiteral.getText() = "" and
      DataFlow::localFlow(DataFlow::exprNode(emptyStrLiteral), ldapBinding.getPassword())
    )
  )
}

// Query to find all LDAP bind operations with improper authentication
from LdapBind ldapBinding
where hasImproperAuthentication(ldapBinding)
select ldapBinding, "The following LDAP bind operation is executed without authentication."