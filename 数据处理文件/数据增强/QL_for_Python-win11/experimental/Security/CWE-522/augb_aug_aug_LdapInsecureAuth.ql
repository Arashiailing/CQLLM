/**
 * @name Python Insecure LDAP Authentication
 * @description Detects LDAP authentication implementations without required security protections
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Core dependencies for LDAP security analysis
import python
import experimental.semmle.python.security.LdapInsecureAuth
import LdapInsecureAuthFlow::PathGraph

// Identify vulnerable authentication paths from source to sink
from LdapInsecureAuthFlow::PathNode sourceNode, LdapInsecureAuthFlow::PathNode sinkNode
where LdapInsecureAuthFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(), sourceNode, sinkNode, "Insecure LDAP authentication detected for this host"