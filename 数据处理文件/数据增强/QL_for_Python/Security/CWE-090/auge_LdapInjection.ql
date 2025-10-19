/**
 * @name LDAP query built from user-controlled sources
 * @description Detects LDAP queries constructed from untrusted user input,
 *              which could allow injection of malicious LDAP commands.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/ldap-injection
 * @tags security
 *       external/cwe/cwe-090
 */

import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from LdapInjectionFlow::PathNode taintedSource, LdapInjectionFlow::PathNode vulnerableSink, string ldapParamName
where
  // Check for data flow to DN parameter
  (LdapInjectionDnFlow::flowPath(taintedSource.asPathNode1(), vulnerableSink.asPathNode1()) and ldapParamName = "DN")
  or
  // Check for data flow to filter parameter
  (LdapInjectionFilterFlow::flowPath(taintedSource.asPathNode2(), vulnerableSink.asPathNode2()) and ldapParamName = "filter")
select vulnerableSink.getNode(), taintedSource, vulnerableSink,
  "LDAP query parameter (" + ldapParamName + ") depends on a $@.", taintedSource.getNode(),
  "user-provided value"