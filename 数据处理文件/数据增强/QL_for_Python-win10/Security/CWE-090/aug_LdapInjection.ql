/**
 * @name LDAP query built from user-controlled sources
 * @description Building an LDAP query from user-controlled sources is vulnerable to insertion of
 *              malicious LDAP code by the user.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/ldap-injection
 * @tags security
 *       external/cwe/cwe-090
 */

// Precision configuration above
import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from LdapInjectionFlow::PathNode origin, LdapInjectionFlow::PathNode target, string paramName
where
  // Check for data flow to DN parameter
  (LdapInjectionDnFlow::flowPath(origin.asPathNode1(), target.asPathNode1()) and paramName = "DN")
  or
  // Check for data flow to filter parameter
  (LdapInjectionFilterFlow::flowPath(origin.asPathNode2(), target.asPathNode2()) and paramName = "filter")
select target.getNode(), origin, target,
  "LDAP query parameter (" + paramName + ") depends on a $@.", origin.getNode(),
  "user-provided value"