/**
 * @name Cookie Construction from Untrusted Input
 * @description Detects cookie creation using user-controlled data that may lead to Cookie Poisoning vulnerabilities
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

// Security analysis module specialized for Cookie Injection detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Visualization components for data flow path representation
import CookieInjectionFlow::PathGraph

// Define malicious input source and vulnerable cookie creation sink
from CookieInjectionFlow::PathNode maliciousSource, CookieInjectionFlow::PathNode vulnerableCookieSink

// Verify data propagation from untrusted input to cookie construction
where CookieInjectionFlow::flowPath(maliciousSource, vulnerableCookieSink)

// Generate security alert with vulnerability details and flow path
select vulnerableCookieSink.getNode(), 
       maliciousSource, 
       vulnerableCookieSink, 
       "Cookie is constructed from $@.", 
       maliciousSource.getNode(), 
       "untrusted user input"