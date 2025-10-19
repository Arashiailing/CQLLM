/**
 * @name Python Insecure LDAP Authentication
 * @description Detects insecure LDAP authentication in Python code, which may expose credentials or use unencrypted connections.
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// This query identifies insecure LDAP authentication flows
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

from LdapInsecureAuthFlow::PathNode authSource, LdapInsecureAuthFlow::PathNode authSink
where LdapInsecureAuthFlow::flowPath(authSource, authSink)
select authSink.getNode(), authSource, authSink, "This LDAP host is authenticated insecurely."