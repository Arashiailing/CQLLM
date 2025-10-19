/**
 * @name Cookie Construction from User-Supplied Input
 * @description Identifies cookie creation using untrusted user input,
 *              potentially enabling Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core Python analysis libraries
import python

// Import specialized modules for cookie injection detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph representation for data flow tracking
import CookieInjectionFlow::PathGraph

// Define path nodes representing tainted input sources and cookie construction sinks
from CookieInjectionFlow::PathNode taintedSource, 
     CookieInjectionFlow::PathNode cookieSink
// Verify data flows from untrusted source to cookie construction
where CookieInjectionFlow::flowPath(taintedSource, cookieSink)
// Report findings with sink location, source node, path details, and contextual message
select cookieSink.getNode(), 
       taintedSource, 
       cookieSink, 
       "Cookie is constructed from a $@.", 
       taintedSource.getNode(),
       "user-supplied input"