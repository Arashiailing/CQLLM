/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies LDAP authentication code lacking essential security controls
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import required modules for analyzing LDAP authentication security
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Find vulnerable authentication flows where data flows from source to sink
from LdapInsecureAuthFlow::PathNode authSource, LdapInsecureAuthFlow::PathNode authSink
where LdapInsecureAuthFlow::flowPath(authSource, authSink)
select authSink.getNode(), authSource, authSink, "Insecure LDAP authentication detected for this host"