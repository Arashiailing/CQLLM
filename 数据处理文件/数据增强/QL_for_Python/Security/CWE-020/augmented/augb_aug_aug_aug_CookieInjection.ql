/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects data flow paths where untrusted user input reaches cookie value assignments,
 *              potentially resulting in injection attacks that undermine cookie security.
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
  CookieInjectionFlow::PathNode untrustedSource, 
  CookieInjectionFlow::PathNode cookieTarget
where 
  CookieInjectionFlow::flowPath(untrustedSource, cookieTarget)
select 
  cookieTarget.getNode(), 
  untrustedSource, 
  cookieTarget, 
  "Cookie value constructed from $@.", 
  untrustedSource.getNode(), 
  "untrusted user input"