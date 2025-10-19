/**
 * @name LDAP query built from user-controlled sources
 * @description Detects LDAP injection vulnerabilities where user input is used to construct
 *              LDAP queries without proper sanitization, potentially allowing malicious
 *              LDAP operations. This query identifies two critical injection points:
 *              Distinguished Name (DN) parameters and search filter parameters.
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

from 
  LdapInjectionFlow::PathNode taintedSource, 
  LdapInjectionFlow::PathNode vulnerableSink, 
  string injectionParam
where 
  // Case 1: Data flow to Distinguished Name (DN) parameter
  (
    LdapInjectionDnFlow::flowPath(taintedSource.asPathNode1(), vulnerableSink.asPathNode1()) 
    and injectionParam = "DN"
  )
  or 
  // Case 2: Data flow to search filter parameter
  (
    LdapInjectionFilterFlow::flowPath(taintedSource.asPathNode2(), vulnerableSink.asPathNode2()) 
    and injectionParam = "filter"
  )
select 
  vulnerableSink.getNode(), 
  taintedSource, 
  vulnerableSink,
  "LDAP query parameter (" + injectionParam + ") depends on a $@.", 
  taintedSource.getNode(),
  "user-provided value"