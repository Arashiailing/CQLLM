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
 * 3. Password as empty string literal
 */
predicate hasInsecureAuth(LdapBind bindOp) {
  // Case 1: Missing password parameter
  not exists(bindOp.getPassword())
  or
  // Case 2: Password derived from None literal
  exists(None noneVal |
    DataFlow::localFlow(DataFlow::exprNode(noneVal), bindOp.getPassword())
  )
  or
  // Case 3: Password as empty string literal
  exists(StringLiteral emptyStr |
    emptyStr.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStr), bindOp.getPassword())
  )
}

// Identify all LDAP bind operations with insecure authentication
from LdapBind bindOp
where hasInsecureAuth(bindOp)
select bindOp, "The following LDAP bind operation is executed without authentication."