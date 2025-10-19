/**
 * @name Construction of a cookie using user-supplied input
 * @description Detects when cookies are constructed from user input, potentially enabling Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Core Python analysis libraries
import python

// Specialized module for Cookie Injection vulnerability detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Data flow path visualization utilities
import CookieInjectionFlow::PathGraph

// Identify data flow sources (user input) and sinks (cookie construction points)
from CookieInjectionFlow::PathNode userInputSource, CookieInjectionFlow::PathNode cookieConstructionSink

// Verify existence of data flow path from user input to cookie construction
where CookieInjectionFlow::flowPath(userInputSource, cookieConstructionSink)

// Generate security alert with path details and vulnerability description
select cookieConstructionSink.getNode(), 
       userInputSource, 
       cookieConstructionSink, 
       "Cookie is constructed from a $@.", 
       userInputSource.getNode(), 
       "user-supplied input"