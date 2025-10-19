/**
 * @name Improper LDAP Authentication
 * @description Identifies LDAP bind operations that lack proper authentication credentials
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
 * Determines if an LDAP bind operation exhibits authentication vulnerabilities
 * by checking for:
 * 1. Missing password parameter
 * 2. Password parameter set to None
 * 3. Password parameter using empty string
 */
predicate exhibitsInsecureAuthentication(LdapBind ldapOperation) {
  // Scenario 1: Password parameter is completely absent
  not exists(ldapOperation.getPassword())
  or
  // Scenario 2: Password parameter explicitly set to None
  exists(None noneValue |
    DataFlow::localFlow(DataFlow::exprNode(noneValue), ldapOperation.getPassword())
  )
  or
  // Scenario 3: Password parameter set to empty string
  exists(StringLiteral emptyStringValue |
    emptyStringValue.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStringValue), ldapOperation.getPassword())
  )
}

// Main query to detect all LDAP bind operations with insecure authentication
from LdapBind ldapOperation
where exhibitsInsecureAuthentication(ldapOperation)
select ldapOperation, "This LDAP bind operation lacks proper authentication credentials."