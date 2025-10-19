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

// Import required modules for analysis
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

// Define a predicate to identify LDAP bind operations with improper authentication
predicate hasImproperAuthentication(LdapBind ldapOperation) {
  // Case 1: Password is either None or not provided
  (
    DataFlow::localFlow(DataFlow::exprNode(any(None noneValue)), ldapOperation.getPassword()) or
    not exists(ldapOperation.getPassword())
  )
  // Case 2: Password is an empty string
  or
  exists(StringLiteral emptyStr |
    emptyStr.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStr), ldapOperation.getPassword())
  )
}

// Find all LDAP bind operations that use improper authentication
from LdapBind ldapOperation
where hasImproperAuthentication(ldapOperation)
select ldapOperation, "The following LDAP bind operation is executed without authentication."