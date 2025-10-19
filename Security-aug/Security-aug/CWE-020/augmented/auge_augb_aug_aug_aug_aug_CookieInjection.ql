/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects data flow paths where untrusted user input propagates to cookie assignments,
 *              potentially leading to injection attacks that compromise cookie integrity.
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
  CookieInjectionFlow::PathNode untrustedInput, 
  CookieInjectionFlow::PathNode cookieAssignment
where 
  CookieInjectionFlow::flowPath(untrustedInput, cookieAssignment)
select 
  cookieAssignment.getNode(), 
  untrustedInput, 
  cookieAssignment, 
  "Cookie value constructed from $@.", 
  untrustedInput.getNode(), 
  "untrusted user input"