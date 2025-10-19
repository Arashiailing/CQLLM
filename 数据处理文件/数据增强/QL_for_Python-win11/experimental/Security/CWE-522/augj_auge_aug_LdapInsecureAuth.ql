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

// Import essential modules for Python security analysis
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Identify insecure LDAP authentication flows
from LdapInsecureAuthFlow::PathNode startNode,
     LdapInsecureAuthFlow::PathNode endNode
where LdapInsecureAuthFlow::flowPath(startNode, endNode)
select endNode.getNode(), startNode, endNode, "This LDAP host is authenticated insecurely."