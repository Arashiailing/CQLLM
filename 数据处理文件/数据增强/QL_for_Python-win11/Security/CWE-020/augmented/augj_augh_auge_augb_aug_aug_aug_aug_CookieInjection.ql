/**
 * @name Untrusted Data Flow to Cookie Assignment
 * @description Detects data flow paths where untrusted user input reaches cookie assignments,
 *              potentially enabling injection attacks that compromise cookie security.
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
  CookieInjectionFlow::PathNode entryPoint, 
  CookieInjectionFlow::PathNode assignmentPoint
where 
  CookieInjectionFlow::flowPath(entryPoint, assignmentPoint)
select 
  assignmentPoint.getNode(), 
  entryPoint, 
  assignmentPoint, 
  "Cookie value constructed from $@.", 
  entryPoint.getNode(), 
  "untrusted user input"