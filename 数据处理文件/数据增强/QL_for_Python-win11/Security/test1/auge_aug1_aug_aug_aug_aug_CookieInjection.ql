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

// Include essential Python analysis framework
import python

// Include specialized security analysis module for detecting Cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Include path visualization module for tracking data flow paths
import CookieInjectionFlow::PathGraph

// Identify data flow source and sink nodes for vulnerability analysis
from 
  CookieInjectionFlow::PathNode originNode, 
  CookieInjectionFlow::PathNode destinationNode
where 
  // Establish data flow connection between untrusted source and cookie creation sink
  exists(CookieInjectionFlow::PathNode intermediateNode |
    CookieInjectionFlow::flowPath(originNode, intermediateNode) and
    CookieInjectionFlow::flowPath(intermediateNode, destinationNode)
  )
// Generate vulnerability report with sink location, source location, flow path, and description
select 
  destinationNode.getNode(), 
  originNode, 
  destinationNode, 
  "Cookie is built using $@.", 
  originNode.getNode(), 
  "untrusted user input"