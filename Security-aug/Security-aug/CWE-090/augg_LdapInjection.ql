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

// Import Python language support and LDAP injection analysis modules
import python
import semmle.python.security.dataflow.LdapInjectionQuery
import LdapInjectionFlow::PathGraph

from 
  LdapInjectionFlow::PathNode injectionSource, 
  LdapInjectionFlow::PathNode vulnerableSink, 
  string paramType
where 
  // Check for data flow paths to DN parameters
  (
    LdapInjectionDnFlow::flowPath(injectionSource.asPathNode1(), vulnerableSink.asPathNode1()) 
    and paramType = "DN"
  )
  or 
  // Check for data flow paths to filter parameters
  (
    LdapInjectionFilterFlow::flowPath(injectionSource.asPathNode2(), vulnerableSink.asPathNode2()) 
    and paramType = "filter"
  )
select 
  vulnerableSink.getNode(), 
  injectionSource, 
  vulnerableSink,
  // Generate alert message with parameter type information
  "LDAP query parameter (" + paramType + ") depends on a $@.", 
  injectionSource.getNode(),
  "user-provided value"