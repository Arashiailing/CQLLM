/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies LDAP authentication implementations vulnerable due to missing security controls
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Core analysis modules for LDAP vulnerability detection
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Locate vulnerable authentication paths in LDAP configurations
from 
  LdapInsecureAuthFlow::PathNode insecureAuthSource,
  LdapInsecureAuthFlow::PathNode insecureAuthTarget
where 
  LdapInsecureAuthFlow::flowPath(insecureAuthSource, insecureAuthTarget)
select 
  insecureAuthTarget.getNode(), 
  insecureAuthSource, 
  insecureAuthTarget, 
  "Insecure LDAP authentication detected for this host"