/**
 * @name LDAP query built from user-controlled sources
 * @description Detects LDAP injection vulnerabilities where user input is used to construct
 *              LDAP queries without proper sanitization, potentially allowing malicious
 *              LDAP operations.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/ldap-injection
 * @tags security
 *       external/cwe/cwe-090
 */

// Core security modules for LDAP injection analysis
import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from LdapInjectionFlow::PathNode sourceNode, LdapInjectionFlow::PathNode sinkNode, string parameterName
where
  // Check for data flow to DN parameter
  (LdapInjectionDnFlow::flowPath(sourceNode.asPathNode1(), sinkNode.asPathNode1()) and 
   parameterName = "DN")
  or
  // Check for data flow to filter parameter
  (LdapInjectionFilterFlow::flowPath(sourceNode.asPathNode2(), sinkNode.asPathNode2()) and 
   parameterName = "filter")
select sinkNode.getNode(), sourceNode, sinkNode,
  "LDAP query parameter (" + parameterName + ") depends on a $@.", sourceNode.getNode(),
  "user-provided value"