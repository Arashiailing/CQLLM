/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies LDAP authentication implementations lacking essential security controls
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

// Identify vulnerable authentication paths where untrusted data flows to LDAP operations
from 
  LdapInsecureAuthFlow::PathNode sourceNode, 
  LdapInsecureAuthFlow::PathNode sinkNode
where 
  LdapInsecureAuthFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "LDAP authentication lacks security controls for this host"