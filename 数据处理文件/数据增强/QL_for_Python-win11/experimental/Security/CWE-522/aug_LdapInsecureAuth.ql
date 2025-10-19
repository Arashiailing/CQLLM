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

// Import necessary modules for Python security analysis
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Identify insecure LDAP authentication flows
from LdapInsecureAuthFlow::PathNode originNode, LdapInsecureAuthFlow::PathNode targetNode
where LdapInsecureAuthFlow::flowPath(originNode, targetNode)
select targetNode.getNode(), originNode, targetNode, "This LDAP host is authenticated insecurely."