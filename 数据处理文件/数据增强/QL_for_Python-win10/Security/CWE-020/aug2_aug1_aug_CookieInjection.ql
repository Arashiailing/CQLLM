/**
 * @name Cookie construction from user-controlled input
 * @description Identifies cookie creation using untrusted input, which could lead to Cookie Poisoning vulnerabilities
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

// Data flow path visualization utilities
import CookieInjectionFlow::PathGraph

// Define source (user input) and sink (cookie construction) variables
from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink

// Verify data flow exists between user input and cookie construction
where CookieInjectionFlow::flowPath(source, sink)

// Generate security alert with vulnerability details
select sink.getNode(), 
       source, 
       sink, 
       "Cookie is constructed from a $@.", 
       source.getNode(), 
       "user-controlled input"