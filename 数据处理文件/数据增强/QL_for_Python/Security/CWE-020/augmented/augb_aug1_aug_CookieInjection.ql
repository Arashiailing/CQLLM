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

// Import Python libraries for code analysis
import python

// Import query module for cookie injection detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph representation for data flow visualization
import CookieInjectionFlow::PathGraph

// Identify data flow paths from untrusted sources to cookie creation sites
from 
  // Source: Represents untrusted input entry points
  CookieInjectionFlow::PathNode sourceNode, 
  // Sink: Represents cookie construction locations
  CookieInjectionFlow::PathNode sinkNode
where 
  // Verify data flows from source to sink
  CookieInjectionFlow::flowPath(sourceNode, sinkNode)
// Output results with sink location, source location, flow path, 
// descriptive message, and source type classification
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cookie is constructed from a $@.", 
  sourceNode.getNode(),
  "user-supplied input"