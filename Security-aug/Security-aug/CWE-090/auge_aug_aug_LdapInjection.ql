/**
 * @name LDAP query built from user-controlled sources
 * @description Identifies LDAP injection vulnerabilities where untrusted user input
 *              is incorporated into LDAP queries without proper sanitization,
 *              potentially enabling unauthorized LDAP operations.
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

from LdapInjectionFlow::PathNode taintedNode, LdapInjectionFlow::PathNode vulnerableNode, string paramName
where
  // Analyze data flow to DN parameter
  (LdapInjectionDnFlow::flowPath(taintedNode.asPathNode1(), vulnerableNode.asPathNode1()) and 
   paramName = "DN")
  or
  // Analyze data flow to filter parameter
  (LdapInjectionFilterFlow::flowPath(taintedNode.asPathNode2(), vulnerableNode.asPathNode2()) and 
   paramName = "filter")
select vulnerableNode.getNode(), taintedNode, vulnerableNode,
  "LDAP query parameter (" + paramName + ") depends on a $@.", taintedNode.getNode(),
  "user-provided value"