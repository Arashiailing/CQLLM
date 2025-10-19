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
predicate hasInsecureAuth(LdapBind bindOperation) {
  // Case 1: Missing password parameter
  not exists(bindOperation.getPassword())
  or
  // Case 2: Password sourced from None literal
  exists(None noneValue |
    DataFlow::localFlow(DataFlow::exprNode(noneValue), bindOperation.getPassword())
  )
  or
  // Case 3: Password using empty string literal
  exists(StringLiteral emptyStr |
    emptyStr.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStr), bindOperation.getPassword())
  )
}

// Identify all LDAP bind operations with insecure authentication patterns
from LdapBind bindOperation
where hasInsecureAuth(bindOperation)
select bindOperation, "The following LDAP bind operation is executed without authentication."