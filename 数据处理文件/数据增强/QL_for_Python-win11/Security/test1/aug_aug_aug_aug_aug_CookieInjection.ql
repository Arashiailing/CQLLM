/**
 * @name Cookie Injection via Untrusted Data Sources
 * @description This query detects potential cookie poisoning vulnerabilities by analyzing data flows from untrusted sources to cookie construction operations.
 *              It identifies when application code uses unsanitized user input to create HTTP cookies.
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

/** 
 * Main query logic: 
 * 1. Identify untrusted data sources (e.g., user inputs)
 * 2. Track data flow through the application
 * 3. Detect cookie creation operations as sinks
 * 4. Report vulnerabilities where untrusted data reaches cookie creation points
 */
from 
  CookieInjectionFlow::PathNode untrustedSourceNode,
  CookieInjectionFlow::PathNode cookieSinkNode
where 
  // Establish valid data flow from untrusted source to cookie sink
  CookieInjectionFlow::flowPath(untrustedSourceNode, cookieSinkNode)

// Output format preserves original structure while improving clarity:
// [sink_location] [source_node] [sink_node] "Vulnerability description" [source_location] [input_type]
select 
  cookieSinkNode.getNode(),
  untrustedSourceNode,
  cookieSinkNode,
  "Cookie is built using $@.",
  untrustedSourceNode.getNode(),
  "untrusted user input"