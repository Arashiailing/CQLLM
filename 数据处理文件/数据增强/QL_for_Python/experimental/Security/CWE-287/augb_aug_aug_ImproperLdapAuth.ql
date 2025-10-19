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
 * Identifies LDAP bind operations with insecure authentication by checking:
 * - Missing password parameter
 * - Password set to None literal
 * - Password set to empty string literal
 */
predicate hasInsecureAuth(LdapBind ldapBind) {
  // Case 1: Password parameter is missing
  not exists(ldapBind.getPassword())
  or
  // Case 2: Password is None literal
  exists(None noneVal |
    DataFlow::localFlow(DataFlow::exprNode(noneVal), ldapBind.getPassword())
  )
  or
  // Case 3: Password is empty string literal
  exists(StringLiteral emptyStr |
    emptyStr.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStr), ldapBind.getPassword())
  )
}

from LdapBind ldapBind
where hasInsecureAuth(ldapBind)
select ldapBind, "The following LDAP bind operation is executed without authentication."