/**
 * @name Python Insecure LDAP Authentication
 * @description Identifies insecure LDAP authentication implementations in Python code
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// Import required CodeQL modules for Python analysis
import python  // Core Python language support
import experimental.semmle.python.security.LdapInsecureAuth  // LDAP security analysis utilities
import LdapInsecureAuthFlow::PathGraph  // Path tracking for insecure LDAP flows

// Define path analysis nodes for source and sink
from LdapInsecureAuthFlow::PathNode sourceNode, LdapInsecureAuthFlow::PathNode sinkNode

// Verify existence of data flow path between source and sink
where LdapInsecureAuthFlow::flowPath(sourceNode, sinkNode)

// Output results with security warning message
select sinkNode.getNode(), sourceNode, sinkNode, "This LDAP host uses insecure authentication."