/**
 * @name Untrusted User Input in Cookie Assignment
 * @description Identifies data flow paths where untrusted user input influences cookie values,
 *              potentially enabling cookie injection attacks that compromise data integrity.
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
  CookieInjectionFlow::PathNode untrustedInputSource, 
  CookieInjectionFlow::PathNode cookieAssignmentTarget
where 
  CookieInjectionFlow::flowPath(untrustedInputSource, cookieAssignmentTarget)
select 
  cookieAssignmentTarget.getNode(), 
  untrustedInputSource, 
  cookieAssignmentTarget, 
  "Cookie value constructed from $@.", 
  untrustedInputSource.getNode(), 
  "untrusted user input"