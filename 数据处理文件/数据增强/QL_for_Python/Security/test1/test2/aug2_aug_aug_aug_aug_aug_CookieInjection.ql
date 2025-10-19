/**
 * @name Untrusted Data Propagation to Cookie Construction
 * @description Detects data flow paths where untrusted user input propagates into cookie value assignments,
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
  CookieInjectionFlow::PathNode untrustedSource, 
  CookieInjectionFlow::PathNode cookieSink, 
  int configurationId
where 
  configurationId = 1
  and CookieInjectionFlow::flowPath(untrustedSource, cookieSink)
select 
  cookieSink.getNode(), 
  untrustedSource, 
  cookieSink, 
  "Cookie value constructed from $@.", 
  untrustedSource.getNode(), 
  "untrusted user input"