/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies vulnerable LDAP authentication configurations missing critical security controls
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Core analysis modules for detecting LDAP authentication vulnerabilities
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Identify authentication paths with insecure LDAP configurations
from 
  LdapInsecureAuthFlow::PathNode entryPoint, 
  LdapInsecureAuthFlow::PathNode vulnerabilitySink
where 
  LdapInsecureAuthFlow::flowPath(entryPoint, vulnerabilitySink)
select 
  vulnerabilitySink.getNode(), 
  entryPoint, 
  vulnerabilitySink, 
  "Insecure LDAP authentication detected for this host"