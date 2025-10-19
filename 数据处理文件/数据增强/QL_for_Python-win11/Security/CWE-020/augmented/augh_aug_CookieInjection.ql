/**
 * @name Cookie Construction from User-Supplied Input
 * @description Detects cookie construction using untrusted user input,
 *              which may enable Cookie Poisoning attacks.
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

// Import specialized cookie injection detection modules
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph representation for data flow tracking
import CookieInjectionFlow::PathGraph

// Define path nodes for tainted input sources and cookie construction sinks
from CookieInjectionFlow::PathNode untrustedInputSource, 
     CookieInjectionFlow::PathNode cookieConstructionSink
// Ensure data flows from untrusted source to cookie sink
where CookieInjectionFlow::flowPath(untrustedInputSource, cookieConstructionSink)
// Report results with sink location, source node, path details, and descriptive message
select cookieConstructionSink.getNode(), 
       untrustedInputSource, 
       cookieConstructionSink, 
       "Cookie is constructed from a $@.", 
       untrustedInputSource.getNode(),
       "user-supplied input"