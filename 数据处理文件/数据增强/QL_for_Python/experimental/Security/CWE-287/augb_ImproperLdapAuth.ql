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

import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

/**
 * Determines if an LDAP bind operation uses improper authentication.
 * This occurs when:
 * 1. Password is derived from None literal or no password is provided
 * 2. Password is derived from an empty string literal
 */
predicate hasImproperAuthentication(LdapBind ldapBinding) {
  // Case 1: Password is None or missing
  (
    DataFlow::localFlow(DataFlow::exprNode(any(None noneLiteral)), ldapBinding.getPassword()) 
    or 
    not exists(ldapBinding.getPassword())
  )
  // Case 2: Password is empty string
  or 
  exists(StringLiteral emptyStrLiteral |
    emptyStrLiteral.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStrLiteral), ldapBinding.getPassword())
  )
}

from LdapBind ldapBinding
where hasImproperAuthentication(ldapBinding)
select ldapBinding, "LDAP bind operation executed without proper authentication credentials."