/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies insecure LDAP authentication patterns in Python applications
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import core analysis modules
import python  // Python language support
import experimental.semmle.python.security.LdapInsecureAuth  // LDAP security analysis
import LdapInsecureAuthFlow::PathGraph  // Path tracking for LDAP flows

// Define source and sink nodes for vulnerability tracking
from LdapInsecureAuthFlow::PathNode sourceNode, LdapInsecureAuthFlow::PathNode sinkNode

// Verify existence of vulnerable data flow path
where LdapInsecureAuthFlow::flowPath(sourceNode, sinkNode)

// Report findings with path context
select sinkNode.getNode(), sourceNode, sinkNode, "Insecure LDAP authentication detected at this host."