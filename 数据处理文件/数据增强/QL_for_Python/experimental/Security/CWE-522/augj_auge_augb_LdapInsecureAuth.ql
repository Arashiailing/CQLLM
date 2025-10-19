/**
 * @name Python Insecure LDAP Authentication
 * @description Detects Python implementations using insecure LDAP authentication methods
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import core Python analysis modules and LDAP security utilities
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Identify insecure authentication flow paths between source and sink
from LdapInsecureAuthFlow::PathNode authSource, LdapInsecureAuthFlow::PathNode authSink
where LdapInsecureAuthFlow::flowPath(authSource, authSink)

// Report results with security context
select authSink.getNode(), authSource, authSink, "LDAP connection configured without secure authentication."