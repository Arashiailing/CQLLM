/**
 * @name LDAP query built from user-controlled sources
 * @description Detects LDAP queries constructed from user-controlled input,
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

from 
  LdapInjectionFlow::PathNode sourceNode, 
  LdapInjectionFlow::PathNode sinkNode, 
  string paramName
where
  // Check for data flow paths to DN parameter
  (
    LdapInjectionDnFlow::flowPath(sourceNode.asPathNode1(), sinkNode.asPathNode1()) 
    and paramName = "DN"
  )
  or
  // Check for data flow paths to filter parameter
  (
    LdapInjectionFilterFlow::flowPath(sourceNode.asPathNode2(), sinkNode.asPathNode2()) 
    and paramName = "filter"
  )
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode,
  // Result includes: sink node, source node, sink node, description, source node, user input description
  "LDAP query parameter (" + paramName + ") depends on a $@.", 
  sourceNode.getNode(),
  "user-provided value"