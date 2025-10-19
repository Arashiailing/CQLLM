/**
 * @name LDAP query constructed from untrusted input
 * @description Identifies LDAP injection vulnerabilities where untrusted user input
 *              is directly incorporated into LDAP queries without sanitization,
 *              potentially enabling unauthorized LDAP operations.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/ldap-injection
 * @tags security
 *       external/cwe/cwe-090
 */

// Core security modules for analyzing LDAP injection vulnerabilities
import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from LdapInjectionFlow::PathNode taintedSource, LdapInjectionFlow::PathNode vulnerableSink, string paramType
where
  // Verify data flow to DN parameter
  (LdapInjectionDnFlow::flowPath(taintedSource.asPathNode1(), vulnerableSink.asPathNode1()) and 
   paramType = "DN")
  or
  // Verify data flow to filter parameter
  (LdapInjectionFilterFlow::flowPath(taintedSource.asPathNode2(), vulnerableSink.asPathNode2()) and 
   paramType = "filter")
select vulnerableSink.getNode(), taintedSource, vulnerableSink,
  "LDAP query parameter (" + paramType + ") incorporates a $@.", taintedSource.getNode(),
  "user-controlled input"