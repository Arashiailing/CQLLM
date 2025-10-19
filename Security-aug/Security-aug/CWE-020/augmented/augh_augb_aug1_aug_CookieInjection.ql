/**
 * @name Cookie construction with user-controlled data
 * @description Building cookies using user-provided input could lead to Cookie Poisoning vulnerabilities.
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

// Import specialized cookie injection detection module
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path visualization components for data flow
import CookieInjectionFlow::PathGraph

// Define data flow tracking variables:
// - taintedSource: Untrusted input entry points
// - cookieSink: Cookie construction locations
from 
  CookieInjectionFlow::PathNode taintedSource,
  CookieInjectionFlow::PathNode cookieSink

// Verify data propagation from untrusted sources to cookie sinks
where 
  CookieInjectionFlow::flowPath(taintedSource, cookieSink)

// Generate results with:
// 1. Sink location (primary finding)
// 2. Source node (for path visualization)
// 3. Sink node (for path visualization)
// 4. Vulnerability description with source type
// 5. Source type classification
select 
  cookieSink.getNode(), 
  taintedSource, 
  cookieSink, 
  "Cookie is constructed from a $@.", 
  taintedSource.getNode(),
  "user-supplied input"