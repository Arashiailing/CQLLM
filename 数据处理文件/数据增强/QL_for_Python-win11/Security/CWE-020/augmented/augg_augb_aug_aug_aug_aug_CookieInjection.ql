/**
 * @name Untrusted User Input in Cookie Assignment
 * @description Detects data flow from untrusted user input to cookie assignments, 
 *              which could lead to cookie injection attacks compromising integrity.
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
  CookieInjectionFlow::PathNode userSource, 
  CookieInjectionFlow::PathNode cookieTarget
where 
  CookieInjectionFlow::flowPath(userSource, cookieTarget)
select 
  cookieTarget.getNode(), 
  userSource, 
  cookieTarget, 
  "Cookie value constructed from $@.", 
  userSource.getNode(), 
  "untrusted user input"