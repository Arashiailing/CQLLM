/**
 * @name Python Insecure LDAP Authentication
 * @description Detects LDAP authentication implementations missing critical security controls
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import core analysis modules for LDAP security assessment
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Identify vulnerable authentication paths where unsecured credentials flow
from LdapInsecureAuthFlow::PathNode vulnerableSource, LdapInsecureAuthFlow::PathNode vulnerableSink
where 
  // Trace data flow from authentication entry point to vulnerable LDAP operation
  LdapInsecureAuthFlow::flowPath(vulnerableSource, vulnerableSink)
select 
  vulnerableSink.getNode(), 
  vulnerableSource, 
  vulnerableSink, 
  "Insecure LDAP authentication detected - missing security controls for this host"