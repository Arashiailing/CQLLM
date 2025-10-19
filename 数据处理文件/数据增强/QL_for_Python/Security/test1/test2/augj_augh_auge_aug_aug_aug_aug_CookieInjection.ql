/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects data flow paths where untrusted user input
 *              is used in cookie value assignments, potentially
 *              enabling injection attacks that compromise cookie integrity.
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
  // Verify direct data flow for cookie injection analysis
  CookieInjectionFlow::flowPath(taintedSource, cookieSink)
select 
  cookieSink.getNode(), 
  taintedSource, 
  cookieSink, 
  "Cookie value constructed from $@.", 
  taintedSource.getNode(), 
  "untrusted user input"