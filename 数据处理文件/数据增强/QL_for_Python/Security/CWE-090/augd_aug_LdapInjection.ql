/**
 * @name LDAP query built from user-controlled sources
 * @description Detects LDAP queries constructed from user input, which allows attackers
 *              to inject malicious LDAP commands via specially crafted input.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/ldap-injection
 * @tags security
 *       external/cwe/cwe-090
 */

// LDAP injection vulnerability detection configuration
import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from LdapInjectionFlow::PathNode sourceNode, LdapInjectionFlow::PathNode sinkNode, string parameterName
where
  // Verify data flow to DN parameter
  (LdapInjectionDnFlow::flowPath(sourceNode.asPathNode1(), sinkNode.asPathNode1()) and parameterName = "DN")
  or
  // Verify data flow to filter parameter
  (LdapInjectionFilterFlow::flowPath(sourceNode.asPathNode2(), sinkNode.asPathNode2()) and parameterName = "filter")
select sinkNode.getNode(), sourceNode, sinkNode,
  "LDAP query parameter (" + parameterName + ") depends on a $@.", sourceNode.getNode(),
  "user-provided value"