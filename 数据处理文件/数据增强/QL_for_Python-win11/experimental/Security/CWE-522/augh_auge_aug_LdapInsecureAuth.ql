/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies potentially vulnerable LDAP authentication configurations
 *              that may expose sensitive credentials or allow unauthorized access.
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import Python language support and LDAP-specific security analysis modules
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Identify and trace insecure LDAP authentication flows from source to sink
from LdapInsecureAuthFlow::PathNode originNode, LdapInsecureAuthFlow::PathNode targetNode
where LdapInsecureAuthFlow::flowPath(originNode, targetNode)
select targetNode.getNode(), 
       originNode, 
       targetNode, 
       "This LDAP host is authenticated insecurely, potentially exposing credentials to interception."