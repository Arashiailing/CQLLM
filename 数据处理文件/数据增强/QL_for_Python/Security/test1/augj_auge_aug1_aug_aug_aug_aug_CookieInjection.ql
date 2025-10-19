/**
 * @name Cookie creation with untrusted user input
 * @description Creating cookies using data from untrusted sources may result in Cookie Poisoning security vulnerabilities.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core Python analysis framework
import python

// Import specialized security analysis module for detecting Cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path visualization module for tracking data flow paths
import CookieInjectionFlow::PathGraph

// Identify data flow source and sink nodes for vulnerability analysis
from 
  CookieInjectionFlow::PathNode sourceNode, 
  CookieInjectionFlow::PathNode sinkNode
where 
  // Establish data flow connection between untrusted source and cookie creation sink
  exists(CookieInjectionFlow::PathNode middleNode |
    CookieInjectionFlow::flowPath(sourceNode, middleNode) and
    CookieInjectionFlow::flowPath(middleNode, sinkNode)
  )
// Generate vulnerability report with sink location, source location, flow path, and description
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cookie is built using $@.", 
  sourceNode.getNode(), 
  "untrusted user input"