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

// Core Python analysis framework
import python

// Security analysis module for detecting Cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Path visualization module for data flow tracking
import CookieInjectionFlow::PathGraph

// Identify data flow source and sink nodes
from 
  CookieInjectionFlow::PathNode sourceNode, 
  CookieInjectionFlow::PathNode sinkNode
where 
  // Verify complete data flow path from untrusted source to cookie creation
  exists(CookieInjectionFlow::PathNode midNode |
    CookieInjectionFlow::flowPath(sourceNode, midNode) and
    CookieInjectionFlow::flowPath(midNode, sinkNode)
  )
// Generate vulnerability report with sink location, source location, flow path, and description
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cookie is built using $@.", 
  sourceNode.getNode(), 
  "untrusted user input"