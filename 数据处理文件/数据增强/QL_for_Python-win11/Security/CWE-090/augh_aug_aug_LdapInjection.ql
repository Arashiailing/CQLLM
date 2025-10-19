/**
 * @name LDAP query built from user-controlled sources
 * @description Identifies LDAP injection vulnerabilities where unsanitized user input
 *              is incorporated into LDAP queries, potentially enabling unauthorized
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

from LdapInjectionFlow::PathNode source, LdapInjectionFlow::PathNode sink, string paramName
where
  // Detect data flow to DN parameter
  (LdapInjectionDnFlow::flowPath(source.asPathNode1(), sink.asPathNode1()) and 
   paramName = "DN")
  or
  // Detect data flow to filter parameter
  (LdapInjectionFilterFlow::flowPath(source.asPathNode2(), sink.asPathNode2()) and 
   paramName = "filter")
select sink.getNode(), source, sink,
  "LDAP query parameter (" + paramName + ") depends on a $@.", source.getNode(),
  "user-provided value"