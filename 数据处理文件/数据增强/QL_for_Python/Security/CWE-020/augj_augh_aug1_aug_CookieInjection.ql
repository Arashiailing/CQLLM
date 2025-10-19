/**
 * @name Cookie Construction from Untrusted Input
 * @description Identifies when cookies are created using user-provided data,
 *              potentially leading to Cookie Poisoning vulnerabilities.
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

// Specialized module for detecting Cookie Injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Path visualization utilities for data flow analysis
import CookieInjectionFlow::PathGraph

// Define source and sink nodes for taint tracking
from CookieInjectionFlow::PathNode maliciousInputSource, 
     CookieInjectionFlow::PathNode vulnerableCookieSink

// Verify data flow propagation from untrusted source to cookie sink
where CookieInjectionFlow::flowPath(maliciousInputSource, vulnerableCookieSink)

// Generate security alert with vulnerability details and flow path
select vulnerableCookieSink.getNode(), 
       maliciousInputSource, 
       vulnerableCookieSink, 
       "Cookie is constructed from a $@.", 
       maliciousInputSource.getNode(), 
       "user-supplied input"