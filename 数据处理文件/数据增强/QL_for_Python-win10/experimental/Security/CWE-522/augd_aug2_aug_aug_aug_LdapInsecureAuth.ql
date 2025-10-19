/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies insecure LDAP authentication methods that do not implement necessary security measures
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Core security analysis modules for LDAP vulnerability detection
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Detect vulnerable authentication paths in LDAP configurations
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