/**
 * @name Construction of a cookie using user-supplied input
 * @description Detects paths where cookies are constructed using untrusted user input,
 *              potentially enabling Cookie Poisoning attacks.
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

// Specialized data flow tracking for cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Path visualization components for data flow results
import CookieInjectionFlow::PathGraph

// Identify dangerous data flow paths from untrusted sources to cookie creation points
from CookieInjectionFlow::PathNode maliciousInputSource, CookieInjectionFlow::PathNode cookieCreationSink
// Establish data flow connection between tainted source and sensitive sink
where CookieInjectionFlow::flowPath(maliciousInputSource, cookieCreationSink)
// Report findings with path context and vulnerability description
select cookieCreationSink.getNode(), 
       maliciousInputSource, 
       cookieCreationSink, 
       "Cookie is constructed from a $@.", 
       maliciousInputSource.getNode(),
       "user-supplied input"