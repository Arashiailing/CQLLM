/**
 * @name Cookie construction from user-controlled data
 * @description Detects cookie poisoning vulnerabilities where cookies are built using 
 *              untrusted user input, allowing attackers to manipulate cookie values
 *              and compromise application security.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core Python analysis framework
import python

// Import specialized cookie injection vulnerability detection module
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph utilities for data flow visualization
import CookieInjectionFlow::PathGraph

// Identify tainted input sources and vulnerable cookie sinks
from CookieInjectionFlow::PathNode taintedSource, CookieInjectionFlow::PathNode cookieSink
// Verify data flow propagation from user input to cookie creation
where CookieInjectionFlow::flowPath(taintedSource, cookieSink)
// Generate vulnerability report with detailed flow information
select 
  cookieSink.getNode(), 
  taintedSource, 
  cookieSink, 
  "Cookie is constructed from a $@.", 
  taintedSource.getNode(),
  "user-controlled input"