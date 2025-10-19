/**
 * @name Untrusted Data Flow to Cookie Assignment
 * @description Identifies data flow paths where untrusted user inputs are used
 *              in cookie value assignments, which could lead to injection
 *              attacks that compromise cookie security.
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
  CookieInjectionFlow::PathNode untrustedInputNode, 
  CookieInjectionFlow::PathNode cookieAssignmentNode
where 
  CookieInjectionFlow::flowPath(untrustedInputNode, cookieAssignmentNode)
select 
  cookieAssignmentNode.getNode(), 
  untrustedInputNode, 
  cookieAssignmentNode, 
  "Cookie value constructed from $@.", 
  untrustedInputNode.getNode(), 
  "untrusted user input"