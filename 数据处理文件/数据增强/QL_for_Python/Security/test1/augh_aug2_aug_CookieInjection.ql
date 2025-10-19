/**
 * @name Cookie creation using untrusted user input
 * @description Building cookies from external input may enable attackers to perform Cookie Poisoning attacks.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import Python analysis libraries
import python

// Import specialized modules for cookie injection analysis
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph representation for data flow tracking
import CookieInjectionFlow::PathGraph

// Identify data flow paths from untrusted sources to cookie construction sinks
from 
  CookieInjectionFlow::PathNode sourceNode, 
  CookieInjectionFlow::PathNode sinkNode
where 
  CookieInjectionFlow::flowPath(sourceNode, sinkNode)
// Output results including sink location, source location, path details, and vulnerability description
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cookie is constructed from a $@.", 
  sourceNode.getNode(),
  "user-supplied input"