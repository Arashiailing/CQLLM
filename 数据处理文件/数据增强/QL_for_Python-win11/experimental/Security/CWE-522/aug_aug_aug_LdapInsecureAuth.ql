/**
 * @name Python Insecure LDAP Authentication
 * @description Detects potentially vulnerable LDAP authentication implementations lacking essential security controls
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

// Identify vulnerable authentication paths through LDAP configurations
from 
  LdapInsecureAuthFlow::PathNode sourceNode, 
  LdapInsecureAuthFlow::PathNode targetNode
where 
  LdapInsecureAuthFlow::flowPath(sourceNode, targetNode)
select 
  targetNode.getNode(), 
  sourceNode, 
  targetNode, 
  "Insecure LDAP authentication detected for this host"