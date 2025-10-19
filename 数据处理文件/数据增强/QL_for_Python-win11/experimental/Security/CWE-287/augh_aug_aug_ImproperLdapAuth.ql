/**
 * @name Improper LDAP Authentication
 * @description Identifies LDAP bind operations that are performed without proper authentication credentials
 * @kind problem
 * @problem.severity warning
 * @id py/improper-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-287
 */

// Import required modules for LDAP operation analysis and data flow tracking
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

/**
 * Detects LDAP bind operations that use insecure authentication methods:
 * 1. No password parameter provided
 * 2. Password parameter set to None
 * 3. Password parameter set to an empty string
 */
predicate hasInsecureAuth(LdapBind ldapOperation) {
  // Case 1: Missing password parameter
  not exists(ldapOperation.getPassword())
  or
  // Case 2: Password is None
  exists(None noneValue |
    DataFlow::localFlow(DataFlow::exprNode(noneValue), ldapOperation.getPassword())
  )
  or
  // Case 3: Password is empty string
  exists(StringLiteral emptyString |
    emptyString.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyString), ldapOperation.getPassword())
  )
}

// Find all LDAP bind operations with insecure authentication
from LdapBind ldapOperation
where hasInsecureAuth(ldapOperation)
select ldapOperation, "The following LDAP bind operation is executed without authentication."