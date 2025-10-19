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

// Identify vulnerable cookie creation paths from untrusted sources
from 
  CookieInjectionFlow::PathNode untrustedSourceNode, 
  CookieInjectionFlow::PathNode cookieCreationSinkNode
where 
  // Verify data flow path exists between untrusted source and cookie sink
  exists(CookieInjectionFlow::PathNode intermediateNode |
    // Data flows from untrusted source to intermediate node
    CookieInjectionFlow::flowPath(untrustedSourceNode, intermediateNode) and
    // Data flows from intermediate node to cookie creation sink
    CookieInjectionFlow::flowPath(intermediateNode, cookieCreationSinkNode)
  )
// Report vulnerability with sink location, source location, flow path, and description
select 
  cookieCreationSinkNode.getNode(), 
  untrustedSourceNode, 
  cookieCreationSinkNode, 
  "Cookie is built using $@.", 
  untrustedSourceNode.getNode(), 
  "untrusted user input"