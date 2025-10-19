/**
 * @name Untrusted Data Flow to Cookie Construction
 * @description Identifies data flow paths from untrusted user input to cookie value assignments,
 *              which could lead to injection attacks that compromise cookie integrity.
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
  CookieInjectionFlow::PathNode maliciousSource, 
  CookieInjectionFlow::PathNode vulnerableCookieSink, 
  int configId
where 
  configId = 1
  and CookieInjectionFlow::flowPath(maliciousSource, vulnerableCookieSink)
select 
  vulnerableCookieSink.getNode(), 
  maliciousSource, 
  vulnerableCookieSink, 
  "Cookie value constructed from $@.", 
  maliciousSource.getNode(), 
  "untrusted user input"