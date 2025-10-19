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

// Detect vulnerable authentication paths through LDAP configurations
from 
  LdapInsecureAuthFlow::PathNode sourceNode,  // Starting point of vulnerable flow
  LdapInsecureAuthFlow::PathNode sinkNode     // Ending point of vulnerable flow
where 
  // Establish data flow path between source and sink
  LdapInsecureAuthFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(),      // Vulnerable endpoint location
  sourceNode,              // Flow origin
  sinkNode,                // Flow destination
  "Insecure LDAP authentication detected for this host"