/**
 * @name Construction of a cookie using user-supplied input
 * @description Building cookies using untrusted user-provided data could lead to a Cookie Poisoning attack, enabling an attacker to manipulate cookie values.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import Python analysis core library
import python

// Import specialized data flow module for cookie injection detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph representation for vulnerability flow tracking
import CookieInjectionFlow::PathGraph

// Define data flow path components: source (untrusted input) and sink (cookie construction)
from CookieInjectionFlow::PathNode taintedSource, CookieInjectionFlow::PathNode cookieConstructionSink

// Validate existence of data flow path between source and sink
where CookieInjectionFlow::flowPath(taintedSource, cookieConstructionSink)

// Generate alert with vulnerability details and flow path
select cookieConstructionSink.getNode(), taintedSource, cookieConstructionSink, 
       "Cookie is constructed from a $@.", taintedSource.getNode(), 
       "user-supplied input"