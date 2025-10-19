/**
 * @name Cookie construction from user-supplied input
 * @description Identifies cookie creation using untrusted user input,
 *              which could enable Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Core Python analysis library import
import python

// Dataflow tracking module for cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Path graph representation for data flow visualization
import CookieInjectionFlow::PathGraph

// Identify data flow paths from untrusted sources to cookie construction sinks
from 
  CookieInjectionFlow::PathNode maliciousInput,  // Source: untrusted user input
  CookieInjectionFlow::PathNode cookieTarget      // Sink: cookie construction site
where 
  CookieInjectionFlow::flowPath(maliciousInput, cookieTarget)
// Report findings with security context and flow visualization
select 
  cookieTarget.getNode(), 
  maliciousInput, 
  cookieTarget,
  "Cookie constructed from $@.", 
  maliciousInput.getNode(),
  "untrusted user input"