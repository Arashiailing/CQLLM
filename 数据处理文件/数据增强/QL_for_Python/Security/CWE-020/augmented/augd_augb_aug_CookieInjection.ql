/**
 * @name Construction of a cookie using user-supplied input
 * @description Building cookies from user-controlled input may enable Cookie Poisoning attacks.
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

// Define data flow source (untrusted user input) and sink (cookie construction)
from 
  CookieInjectionFlow::PathNode taintedSource,  // User-controlled input origin
  CookieInjectionFlow::PathNode cookieSink      // Cookie assembly point
// Validate data flow path existence
where CookieInjectionFlow::flowPath(taintedSource, cookieSink)
// Output sink location, source details, path, and security message
select 
  cookieSink.getNode(), 
  taintedSource, 
  cookieSink, 
  "Cookie is constructed from a $@.", 
  taintedSource.getNode(),
  "user-supplied input"