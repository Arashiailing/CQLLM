/**
 * @name Cookie Construction from Untrusted Input
 * @description Detects cookie creation using user-controllable data, potentially enabling Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Core Python language support and security analysis frameworks
import python

// Specialized module for tracking data flows in Cookie Injection scenarios
import semmle.python.security.dataflow.CookieInjectionQuery

// Path visualization components for vulnerability flow representation
import CookieInjectionFlow::PathGraph

// Identify untrusted input sources and cookie creation sinks
from CookieInjectionFlow::PathNode maliciousInputSource, 
     CookieInjectionFlow::PathNode cookieCreationSink

// Validate data flow propagation between source and sink
where CookieInjectionFlow::flowPath(maliciousInputSource, cookieCreationSink)

// Generate security alert with vulnerability details and flow path
select cookieCreationSink.getNode(), 
       maliciousInputSource, 
       cookieCreationSink, 
       "Cookie is constructed from $@.", 
       maliciousInputSource.getNode(), 
       "untrusted user input"