/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects data flow paths where untrusted user input flows into cookie assignments,
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
  CookieInjectionFlow::PathNode untrustedInputSource, 
  CookieInjectionFlow::PathNode cookieSink
where 
  exists(int configId | 
    configId = 1
  ) and 
  CookieInjectionFlow::flowPath(untrustedInputSource, cookieSink)
select 
  cookieSink.getNode(), 
  untrustedInputSource, 
  cookieSink, 
  "Cookie value constructed from $@.", 
  untrustedInputSource.getNode(), 
  "untrusted user input"