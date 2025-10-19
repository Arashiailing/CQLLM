/**
 * @name LDAP query built from user-controlled sources
 * @description Identifies LDAP injection vulnerabilities where user input is 
 *              used to construct LDAP queries without sanitization. Detects 
 *              two critical injection points: Distinguished Name (DN) 
 *              parameters and search filter parameters.
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
  LdapInjectionFlow::PathNode sourceNode, 
  LdapInjectionFlow::PathNode sinkNode, 
  string paramType
where 
  // Case 1: Data flow to Distinguished Name (DN) parameter
  (LdapInjectionDnFlow::flowPath(sourceNode.asPathNode1(), sinkNode.asPathNode1()) 
   and paramType = "DN")
  or 
  // Case 2: Data flow to search filter parameter
  (LdapInjectionFilterFlow::flowPath(sourceNode.asPathNode2(), sinkNode.asPathNode2()) 
   and paramType = "filter")
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode,
  "LDAP query parameter (" + paramType + ") depends on a $@.", 
  sourceNode.getNode(),
  "user-provided value"