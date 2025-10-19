/**
 * @name Python Insecure LDAP Authentication
 * @description Detects insecure LDAP authentication in Python applications
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import required modules for Python security analysis
import python  // Core Python language support
import experimental.semmle.python.security.LdapInsecureAuth  // LDAP vulnerability detection
import LdapInsecureAuthFlow::PathGraph  // Path tracking for insecure LDAP flows

// Identify vulnerable authentication flow endpoints
from LdapInsecureAuthFlow::PathNode sourceNode, LdapInsecureAuthFlow::PathNode sinkNode

// Verify existence of insecure authentication path
where LdapInsecureAuthFlow::flowPath(sourceNode, sinkNode)

// Report findings with path context
select sinkNode.getNode(), sourceNode, sinkNode, "This LDAP host is authenticated insecurely."