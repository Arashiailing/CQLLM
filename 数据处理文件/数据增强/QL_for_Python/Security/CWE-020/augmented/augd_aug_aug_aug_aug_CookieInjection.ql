/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Identifies data flow paths where untrusted user input reaches cookie assignments,
 *              potentially enabling injection attacks that compromise cookie integrity.
 * @id py/untrusted-cookie-injection
 * @kind path-problem
 * @precision low
 * @problem.severity error
 * @security-severity 8.7
 * @tags security external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.CookieInjectionQuery
import CookieInjectionFlow::PathGraph

from 
  CookieInjectionFlow::PathNode taintedInputNode, 
  CookieInjectionFlow::PathNode cookieAssignmentNode
where 
  CookieInjectionFlow::flowPath(taintedInputNode, cookieAssignmentNode)
select 
  cookieAssignmentNode.getNode(), 
  taintedInputNode, 
  cookieAssignmentNode, 
  "Cookie value constructed from $@.", 
  taintedInputNode.getNode(), 
  "untrusted user input"