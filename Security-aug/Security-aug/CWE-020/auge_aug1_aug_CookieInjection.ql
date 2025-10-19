/**
 * @name Cookie construction from user input
 * @description Identifies cookie objects created using untrusted user input,
 *              which may lead to Cookie Poisoning vulnerabilities.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core Python analysis libraries
import python

// Import specialized Cookie Injection vulnerability detection module
import semmle.python.security.dataflow.CookieInjectionQuery

// Import data flow path visualization utilities
import CookieInjectionFlow::PathGraph

// Define data flow source (user input) and sink (cookie construction)
from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink

// Verify data flow path exists from user input to cookie construction
where CookieInjectionFlow::flowPath(source, sink)

// Generate security alert with vulnerability details and flow path
select sink.getNode(), 
       source, 
       sink, 
       "Cookie is constructed from a $@.", 
       source.getNode(), 
       "user-supplied input"