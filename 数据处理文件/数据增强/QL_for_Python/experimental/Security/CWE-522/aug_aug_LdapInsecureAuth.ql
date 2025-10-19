/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies vulnerable LDAP authentication configurations lacking proper security controls
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Core imports for LDAP vulnerability analysis
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Trace vulnerable authentication paths from origin to destination
from LdapInsecureAuthFlow::PathNode originNode, LdapInsecureAuthFlow::PathNode destinationNode
where LdapInsecureAuthFlow::flowPath(originNode, destinationNode)
select destinationNode.getNode(), originNode, destinationNode, "Insecure LDAP authentication detected for this host"