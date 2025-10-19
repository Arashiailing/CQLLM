/**
 * @name LDAP query built from user-controlled sources
 * @description Detects construction of LDAP queries using user-provided input,
 *              which could allow injection of malicious LDAP operations.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/ldap-injection
 * @tags security
 *       external/cwe/cwe-090
 */

// Import core security analysis modules
import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from 
  LdapInjectionFlow::PathNode source, 
  LdapInjectionFlow::PathNode sink, 
  string paramType
where
  // Check data flow to distinguished name (DN) parameter
  (LdapInjectionDnFlow::flowPath(source.asPathNode1(), sink.asPathNode1()) and paramType = "DN")
  or
  // Check data flow to filter parameter
  (LdapInjectionFilterFlow::flowPath(source.asPathNode2(), sink.asPathNode2()) and paramType = "filter")
select 
  sink.getNode(), 
  source, 
  sink,
  "LDAP query parameter (" + paramType + ") incorporates $@.", 
  source.getNode(),
  "user-controlled input"