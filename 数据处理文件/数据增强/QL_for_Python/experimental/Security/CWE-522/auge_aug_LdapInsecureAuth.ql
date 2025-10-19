/**
 * @name Python Insecure LDAP Authentication
 * @description Detects insecure LDAP authentication configurations in Python code
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

// Detect insecure LDAP authentication flows
from LdapInsecureAuthFlow::PathNode sourceNode, LdapInsecureAuthFlow::PathNode sinkNode
where LdapInsecureAuthFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(), sourceNode, sinkNode, "This LDAP host is authenticated insecurely."