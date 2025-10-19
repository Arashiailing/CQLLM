/**
 * @name Malicious Input Propagation to Cookie Construction
 * @description Detects data flow paths where untrusted user inputs propagate to cookie value creation,
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
  CookieInjectionFlow::PathNode maliciousSource, 
  CookieInjectionFlow::PathNode vulnerableSink, 
  int configId
where 
  configId = 1 and
  CookieInjectionFlow::flowPath(maliciousSource, vulnerableSink)
select 
  vulnerableSink.getNode(), 
  maliciousSource, 
  vulnerableSink, 
  "Cookie value constructed from $@.", 
  maliciousSource.getNode(), 
  "untrusted user input"