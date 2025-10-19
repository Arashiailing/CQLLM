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

/**
 * Checks if LDAP bind operation uses None as password
 * or completely omits password parameter
 */
predicate hasMissingOrNonePassword(LdapBind bindOperation) {
  // Case 1: Password parameter is explicitly set to None
  DataFlow::localFlow(DataFlow::exprNode(any(None noneValue)), bindOperation.getPassword())
  or
  // Case 2: Password parameter is not provided at all
  not exists(bindOperation.getPassword())
}

/**
 * Checks if LDAP bind operation uses empty string as password
 */
predicate hasEmptyStringPassword(LdapBind bindOperation) {
  exists(StringLiteral emptyStr |
    emptyStr.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStr), bindOperation.getPassword())
  )
}

/**
 * Combines checks for all forms of improper LDAP authentication
 */
predicate hasImproperAuthentication(LdapBind bindOperation) {
  // Detect either missing/None password OR empty string password
  hasMissingOrNonePassword(bindOperation) or
  hasEmptyStringPassword(bindOperation)
}

// Find all LDAP bind operations that use improper authentication
from LdapBind bindOperation
where hasImproperAuthentication(bindOperation)
select bindOperation, "The following LDAP bind operation is executed without authentication."