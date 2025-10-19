/**
 * @name Cookie creation with untrusted user input
 * @description Constructing cookies using data from untrusted sources can lead to Cookie Poisoning vulnerabilities.
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

// Import specialized security analysis module for Cookie injection detection
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path visualization module for data flow tracking
import CookieInjectionFlow::PathGraph

// Define data flow source and sink nodes for vulnerability detection
from 
  CookieInjectionFlow::PathNode sourceNode, 
  CookieInjectionFlow::PathNode sinkNode
where 
  // Establish data flow connection between untrusted source and cookie creation sink
  exists(CookieInjectionFlow::PathNode midNode |
    CookieInjectionFlow::flowPath(sourceNode, midNode) and
    CookieInjectionFlow::flowPath(midNode, sinkNode)
  )
// Report vulnerability with sink location, source location, flow path, and description
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cookie is built using $@.", 
  sourceNode.getNode(), 
  "untrusted user input"