/**
 * @name Untrusted Data Flow into Cookie Value Assignment
 * @description Detects data flow paths where untrusted user input propagates to cookie value assignments,
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
  CookieInjectionFlow::PathNode taintedSource, 
  CookieInjectionFlow::PathNode cookieSink
where 
  exists(int flowConfig | 
    flowConfig = 1 and 
    CookieInjectionFlow::flowPath(taintedSource, cookieSink)
  )
select 
  cookieSink.getNode(), 
  taintedSource, 
  cookieSink, 
  "Cookie value constructed from $@.", 
  taintedSource.getNode(), 
  "untrusted user input"