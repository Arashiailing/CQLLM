/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies Python code with insecure LDAP authentication configurations
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import required modules for Python security analysis
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Define source and sink nodes for insecure LDAP authentication flows
from LdapInsecureAuthFlow::PathNode sourceNode,
     LdapInsecureAuthFlow::PathNode sinkNode
where LdapInsecureAuthFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(),
       sourceNode,
       sinkNode,
       "This LDAP host is authenticated insecurely."