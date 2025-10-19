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

// Import necessary libraries for Python analysis and LDAP injection detection
import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from LdapInjectionFlow::PathNode userInput, LdapInjectionFlow::PathNode ldapEndpoint, string vulnParameter
where
  // Check for DN parameter vulnerability
  (LdapInjectionDnFlow::flowPath(userInput.asPathNode1(), ldapEndpoint.asPathNode1()) and
   vulnParameter = "DN")
  or
  // Check for filter parameter vulnerability
  (LdapInjectionFilterFlow::flowPath(userInput.asPathNode2(), ldapEndpoint.asPathNode2()) and
   vulnParameter = "filter")
select ldapEndpoint.getNode(), userInput, ldapEndpoint,
  // Generate alert message with parameter type and reference to user input source
  "LDAP query parameter (" + vulnParameter + ") depends on a $@.", userInput.getNode(),
  "user-provided value"