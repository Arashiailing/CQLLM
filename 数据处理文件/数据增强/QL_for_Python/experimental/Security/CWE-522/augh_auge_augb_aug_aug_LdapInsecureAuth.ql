/**
 * @name Python Insecure LDAP Authentication
 * @description Detects LDAP authentication implementations missing critical security protections
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import core analysis modules for LDAP security vulnerability detection
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Identify vulnerable authentication paths where untrusted data flows to LDAP operations
from 
  LdapInsecureAuthFlow::PathNode insecureAuthSource, 
  LdapInsecureAuthFlow::PathNode insecureAuthSink
where 
  LdapInsecureAuthFlow::flowPath(insecureAuthSource, insecureAuthSink)
select 
  insecureAuthSink.getNode(), 
  insecureAuthSource, 
  insecureAuthSink, 
  "LDAP authentication lacks security controls for this host"