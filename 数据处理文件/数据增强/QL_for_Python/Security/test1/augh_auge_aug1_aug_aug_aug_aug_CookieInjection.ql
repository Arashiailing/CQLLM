/**
 * @name Cookie Poisoning via Untrusted Input
 * @description This query detects when cookies are created using data from untrusted sources, which can lead to Cookie Poisoning vulnerabilities.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import the core Python analysis framework
import python

// Import the security analysis module for Cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Import the path graph module for visualizing data flow
import CookieInjectionFlow::PathGraph

// Define source and sink nodes for the data flow analysis
from 
  CookieInjectionFlow::PathNode sourceNode, 
  CookieInjectionFlow::PathNode sinkNode
where 
  // Connect the untrusted source to the cookie creation sink via an intermediate node
  exists(CookieInjectionFlow::PathNode midNode | 
    CookieInjectionFlow::flowPath(sourceNode, midNode) and 
    CookieInjectionFlow::flowPath(midNode, sinkNode)
  )
// Output the vulnerability report including sink, source, path, and a descriptive message
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "Cookie is built using $@.", 
  sourceNode.getNode(), 
  "untrusted user input"