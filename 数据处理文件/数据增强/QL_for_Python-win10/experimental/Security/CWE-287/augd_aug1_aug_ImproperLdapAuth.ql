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
predicate hasInsecureAuth(LdapBind ldapBind) {
  // Case 1: Missing password parameter
  not exists(ldapBind.getPassword())
  or
  // Case 2: Password parameter is None
  exists(None noneNode |
    DataFlow::localFlow(DataFlow::exprNode(noneNode), ldapBind.getPassword())
  )
  or
  // Case 3: Password parameter is empty string
  exists(StringLiteral emptyStrNode |
    emptyStrNode.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStrNode), ldapBind.getPassword())
  )
}

// Identify all LDAP bind operations with insecure authentication patterns
from LdapBind ldapBind
where hasInsecureAuth(ldapBind)
select ldapBind, "The following LDAP bind operation is executed without authentication."