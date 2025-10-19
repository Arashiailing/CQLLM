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
  CookieInjectionFlow::PathNode untrustedSource, 
  CookieInjectionFlow::PathNode cookieSink
where 
  // Identify intermediate node in data flow path
  exists(CookieInjectionFlow::PathNode intermediateNode |
    // Track data flow from untrusted source to intermediate node
    CookieInjectionFlow::flowPath(untrustedSource, intermediateNode) and
    // Track data flow from intermediate node to cookie creation sink
    CookieInjectionFlow::flowPath(intermediateNode, cookieSink)
  )
// Report vulnerability with sink location, source location, flow path, and description
select 
  cookieSink.getNode(), 
  untrustedSource, 
  cookieSink, 
  "Cookie is built using $@.", 
  untrustedSource.getNode(), 
  "untrusted user input"