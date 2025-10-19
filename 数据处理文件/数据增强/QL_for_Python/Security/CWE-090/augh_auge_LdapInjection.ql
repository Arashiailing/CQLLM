/**
 * @name LDAP query built from user-controlled sources
 * @description Detects LDAP queries constructed from untrusted input,
 *              which could enable injection of malicious LDAP commands.
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

// Define variables for tracking data flow paths and parameter types
from LdapInjectionFlow::PathNode untrustedSource, LdapInjectionFlow::PathNode ldapSink, string parameterType
where
  // Check for data flow to DN parameter
  (
    LdapInjectionDnFlow::flowPath(untrustedSource.asPathNode1(), ldapSink.asPathNode1())
    and parameterType = "DN"
  )
  or
  // Check for data flow to filter parameter
  (
    LdapInjectionFilterFlow::flowPath(untrustedSource.asPathNode2(), ldapSink.asPathNode2())
    and parameterType = "filter"
  )
select ldapSink.getNode(), untrustedSource, ldapSink,
  "LDAP query parameter (" + parameterType + ") depends on a $@.", untrustedSource.getNode(),
  "user-provided value"