/**
 * @name Cookie construction from untrusted input
 * @description Building cookies with user-controlled data enables Cookie Poisoning attacks
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Core Python analysis modules
import python

// Cookie injection data flow definitions
import semmle.python.security.dataflow.CookieInjectionQuery

// Path graph visualization components
import CookieInjectionFlow::PathGraph

// Identify data flow paths between tainted sources and cookie sinks
from 
  CookieInjectionFlow::PathNode userInputSource,  // User-controlled data entry point
  CookieInjectionFlow::PathNode cookieSink         // Cookie construction location
// Validate data flow connectivity
where CookieInjectionFlow::flowPath(userInputSource, cookieSink)
// Report findings with vulnerability context
select 
  cookieSink.getNode(), 
  userInputSource, 
  cookieSink, 
  "Cookie built from $@.", 
  userInputSource.getNode(),
  "untrusted user input"