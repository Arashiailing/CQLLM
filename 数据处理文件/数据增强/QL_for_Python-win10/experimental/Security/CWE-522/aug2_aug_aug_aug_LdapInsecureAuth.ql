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

// Core analysis modules for LDAP vulnerability detection
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Identify vulnerable authentication paths through LDAP configurations
from 
  LdapInsecureAuthFlow::PathNode startNode,
  LdapInsecureAuthFlow::PathNode endNode
where 
  LdapInsecureAuthFlow::flowPath(startNode, endNode)
select 
  endNode.getNode(), 
  startNode, 
  endNode, 
  "Insecure LDAP authentication detected for this host"