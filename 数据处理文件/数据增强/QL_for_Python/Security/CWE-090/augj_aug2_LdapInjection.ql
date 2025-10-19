/**
 * @name LDAP query built from user-controlled sources
 * @description Detects LDAP queries constructed from untrusted input sources,
 *              which could allow injection of malicious LDAP commands.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/ldap-injection
 * @tags security
 *       external/cwe/cwe-090
 */

// Import necessary libraries for Python analysis and LDAP injection detection
import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from LdapInjectionFlow::PathNode untrustedSource, LdapInjectionFlow::PathNode ldapSink, string paramType
where
  // Check for DN parameter vulnerability
  (LdapInjectionDnFlow::flowPath(untrustedSource.asPathNode1(), ldapSink.asPathNode1()) and
   paramType = "DN")
  or
  // Check for filter parameter vulnerability
  (LdapInjectionFilterFlow::flowPath(untrustedSource.asPathNode2(), ldapSink.asPathNode2()) and
   paramType = "filter")
select ldapSink.getNode(), untrustedSource, ldapSink,
  // Generate alert message with parameter type and reference to user input source
  "LDAP query parameter (" + paramType + ") depends on a $@.", untrustedSource.getNode(),
  "user-provided value"