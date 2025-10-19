/**
 * @name Cookie construction with user-controlled data
 * @description Detects potential Cookie Poisoning vulnerabilities where cookies
 *              are built using untrusted user input without proper sanitization.
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

// Import path graph visualization components
import CookieInjectionFlow::PathGraph

// Define data flow analysis components
from 
  // Source node representing untrusted user input
  CookieInjectionFlow::PathNode sourceNode,
  // Sink node where cookies are constructed
  CookieInjectionFlow::PathNode sinkNode
where 
  // Establish data flow from untrusted source to cookie construction
  CookieInjectionFlow::flowPath(sourceNode, sinkNode)
// Output results with sink location, source location, flow path,
// descriptive message, and source classification
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cookie is constructed from a $@.", 
  sourceNode.getNode(),
  "user-supplied input"