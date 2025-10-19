/**
 * @name Untrusted Input in Cookie Value Construction
 * @description Detects data flow paths where untrusted user input (e.g., HTTP request parameters)
 *              is used to build cookie values. This may enable injection attacks compromising
 *              cookie integrity, leading to session hijacking or security bypasses.
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
  CookieInjectionFlow::PathNode cookieValueSink, 
  int flowConfigId
where 
  flowConfigId = 1 and
  CookieInjectionFlow::flowPath(untrustedInputSource, cookieValueSink)
select 
  cookieValueSink.getNode(), 
  untrustedInputSource, 
  cookieValueSink, 
  "Cookie value constructed from $@.", 
  untrustedInputSource.getNode(), 
  "untrusted user input"