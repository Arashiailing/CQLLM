/**
 * @name Improper LDAP Authentication
 * @description Detects LDAP bind operations that are performed without proper authentication credentials,
 *              which could lead to unauthorized access to directory services.
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
 * Holds if the specified LDAP bind operation uses insecure authentication.
 * This occurs when:
 *   - No password parameter is provided
 *   - Password is explicitly set to None
 *   - Password is an empty string
 */
predicate hasInsecureAuth(LdapBind bindOp) {
  // Case 1: Missing password parameter
  not exists(bindOp.getPassword())
  or
  // Case 2: Password is None (no authentication)
  exists(None noneVal |
    DataFlow::localFlow(DataFlow::exprNode(noneVal), bindOp.getPassword())
  )
  or
  // Case 3: Password is empty string (equivalent to no password)
  exists(StringLiteral emptyStr |
    emptyStr.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStr), bindOp.getPassword())
  )
}

from LdapBind ldapOperation
where hasInsecureAuth(ldapOperation)
select ldapOperation, "The following LDAP bind operation is executed without authentication."