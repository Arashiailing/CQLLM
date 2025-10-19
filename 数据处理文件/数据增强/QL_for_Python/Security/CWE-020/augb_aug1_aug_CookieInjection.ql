/**
 * @name Cookie Construction from Untrusted Input
 * @description Identifies cookie creation using user-controlled data, which may lead to Cookie Poisoning vulnerabilities.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Core Python language support and analysis frameworks
import python

// Specialized security analysis module for Cookie Injection detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Visualization components for data flow path representation
import CookieInjectionFlow::PathGraph

// Define data flow source (untrusted user input) and sink (cookie creation point)
from CookieInjectionFlow::PathNode untrustedSource, CookieInjectionFlow::PathNode cookieSink

// Verify data flow propagation between source and sink
where CookieInjectionFlow::flowPath(untrustedSource, cookieSink)

// Generate security alert with vulnerability details and flow path
select cookieSink.getNode(), 
       untrustedSource, 
       cookieSink, 
       "Cookie is constructed from $@.", 
       untrustedSource.getNode(), 
       "untrusted user input"