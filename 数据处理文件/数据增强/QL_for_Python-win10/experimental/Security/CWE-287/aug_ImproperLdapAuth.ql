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
 * Determines if an LDAP bind operation uses improper authentication
 * by checking for three insecure password conditions:
 * 1. Password parameter is completely absent
 * 2. Password originates from None literal
 * 3. Password is an empty string literal
 */
predicate hasInsecureAuth(LdapBind ldapBind) {
  // Case 1: No password parameter provided
  not exists(ldapBind.getPassword())
  or
  // Case 2: Password comes from None literal
  exists(None noneNode |
    DataFlow::localFlow(DataFlow::exprNode(noneNode), ldapBind.getPassword())
  )
  or
  // Case 3: Password is empty string literal
  exists(StringLiteral emptyStr |
    emptyStr.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStr), ldapBind.getPassword())
  )
}

// Identify all LDAP bind operations with insecure authentication
from LdapBind ldapBind
where hasInsecureAuth(ldapBind)
select ldapBind, "The following LDAP bind operation is executed without authentication."