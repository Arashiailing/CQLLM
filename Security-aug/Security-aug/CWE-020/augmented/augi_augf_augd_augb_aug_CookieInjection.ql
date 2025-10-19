/**
 * @name Cookie constructed from user input
 * @description Detects cookie construction using untrusted user input, which can lead to Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.CookieInjectionQuery
import CookieInjectionFlow::PathGraph

// Identify data flow from untrusted sources to cookie construction sinks
from 
  CookieInjectionFlow::PathNode userInputSource,    // Origin of untrusted data
  CookieInjectionFlow::PathNode cookieSink           // Location where cookie is created
where 
  CookieInjectionFlow::flowPath(userInputSource, cookieSink)
select 
  cookieSink.getNode(), 
  userInputSource, 
  cookieSink, 
  "Cookie is constructed from a $@.", 
  userInputSource.getNode(),
  "user-supplied input"