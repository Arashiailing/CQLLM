/**
 * @name Cookie Construction from Untrusted Input
 * @description Detects cookie creation using user-controllable data, potentially leading to Cookie Poisoning vulnerabilities.
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

// Specialized module for Cookie Injection vulnerability detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Visualization components for data flow path representation
import CookieInjectionFlow::PathGraph

// Define untrusted input source and cookie creation sink
from CookieInjectionFlow::PathNode untrustedInputSource, CookieInjectionFlow::PathNode cookieCreationSink

// Verify data flow propagation from source to sink
where CookieInjectionFlow::flowPath(untrustedInputSource, cookieCreationSink)

// Generate security alert with vulnerability details and flow path
select cookieCreationSink.getNode(), 
       untrustedInputSource, 
       cookieCreationSink, 
       "Cookie is constructed from $@.", 
       untrustedInputSource.getNode(), 
       "untrusted user input"