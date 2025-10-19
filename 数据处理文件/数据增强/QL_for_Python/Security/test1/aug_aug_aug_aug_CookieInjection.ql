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

// Identify data flow paths from untrusted inputs to cookie creation points
from 
  CookieInjectionFlow::PathNode untrustedInputNode, 
  CookieInjectionFlow::PathNode cookieCreationNode
where 
  // Verify data flow exists between untrusted source and cookie sink
  CookieInjectionFlow::flowPath(untrustedInputNode, cookieCreationNode)
// Report vulnerability with sink location, source location, flow path, and description
select 
  cookieCreationNode.getNode(), 
  untrustedInputNode, 
  cookieCreationNode, 
  "Cookie is built using $@.", 
  untrustedInputNode.getNode(), 
  "untrusted user input"