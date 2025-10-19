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
 * Determines if an LDAP bind operation uses insecure authentication by examining
 * the password parameter for common security weaknesses.
 */
predicate hasInsecureAuth(LdapBind ldapOperation) {
  // Check for missing password parameter in the LDAP bind operation
  not exists(ldapOperation.getPassword())
  or
  // Check if password is explicitly set to None, indicating no authentication
  exists(None noneLiteral |
    DataFlow::localFlow(DataFlow::exprNode(noneLiteral), ldapOperation.getPassword())
  )
  or
  // Check if password is an empty string, which is equivalent to no password
  exists(StringLiteral emptyStringLiteral |
    emptyStringLiteral.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyStringLiteral), ldapOperation.getPassword())
  )
}

from LdapBind ldapOperation
where hasInsecureAuth(ldapOperation)
select ldapOperation, "The following LDAP bind operation is executed without authentication."