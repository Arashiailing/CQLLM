/**
 * @name Cookie creation with untrusted user input
 * @description Constructing cookies using data from untrusted sources can lead to Cookie Poisoning vulnerabilities.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Core Python analysis libraries for security detection
import python

// Specialized data flow analysis module for Cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Path visualization component for data flow tracking
import CookieInjectionFlow::PathGraph

// Identify vulnerable data flows from untrusted inputs to cookie creation points
from 
  CookieInjectionFlow::PathNode untrustedInputSource, 
  CookieInjectionFlow::PathNode cookieCreationSink
where 
  // Verify complete data flow path exists between source and sink
  CookieInjectionFlow::flowPath(untrustedInputSource, cookieCreationSink)
// Report vulnerability with sink location, source location, flow path, and contextual message
select 
  cookieCreationSink.getNode(), 
  untrustedInputSource, 
  cookieCreationSink, 
  "Cookie is built using $@.", 
  untrustedInputSource.getNode(), 
  "untrusted user input"