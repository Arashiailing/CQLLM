/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies insecure LDAP authentication configurations in Python code
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Core imports for Python security analysis
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Find insecure LDAP authentication paths between source and sink
from 
  LdapInsecureAuthFlow::PathNode sourceNode,  // Origin of insecure data flow
  LdapInsecureAuthFlow::PathNode sinkNode     // Destination of insecure data flow
where 
  LdapInsecureAuthFlow::flowPath(sourceNode, sinkNode)  // Path existence condition
select 
  sinkNode.getNode(),        // Vulnerable location in code
  sourceNode,                // Flow source node
  sinkNode,                  // Flow sink node
  "This LDAP host is authenticated insecurely."  // Alert message