/**
 * @name Python Insecure LDAP Authentication
 * @description Detects insecure LDAP authentication flows in Python code that may expose credentials
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Track insecure authentication flows from source to sink
from LdapInsecureAuthFlow::PathNode origin, LdapInsecureAuthFlow::PathNode destination
where LdapInsecureAuthFlow::flowPath(origin, destination)
select destination.getNode(), origin, destination, "This LDAP host is authenticated insecurely."