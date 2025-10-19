/**
 * @name Cookie construction with user-controlled data
 * @description Detects potential Cookie Poisoning vulnerabilities by tracking data flow
 *              from untrusted user inputs to cookie construction sites.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/cookie-injection
 * @tags security
 *       external/cwe/cwe-20
 */

// Import core Python analysis capabilities
import python

// Import specialized data flow analysis module for detecting cookie injection vulnerabilities
import semmle.python.security.dataflow.CookieInjectionQuery

// Import path graph utilities for visualizing data flow paths
import CookieInjectionFlow::PathGraph

// Define the query to identify vulnerable cookie construction patterns
from 
  // Entry point representing untrusted user input that could be malicious
  CookieInjectionFlow::PathNode untrustedInputNode,
  // Target location where cookies are being constructed
  CookieInjectionFlow::PathNode cookieConstructionNode
where 
  // Establish data flow relationship between untrusted input and cookie construction
  CookieInjectionFlow::flowPath(untrustedInputNode, cookieConstructionNode)
// Generate results showing the complete vulnerability path
select 
  // Primary location where the vulnerability manifests (cookie construction)
  cookieConstructionNode.getNode(), 
  // Origin of the tainted data (untrusted input)
  untrustedInputNode, 
  // Destination of the tainted data (cookie construction)
  cookieConstructionNode, 
  // Descriptive message explaining the security issue
  "Cookie is constructed from a $@.", 
  // Reference to the source node for message formatting
  untrustedInputNode.getNode(),
  // Classification of the source as user-supplied input
  "user-supplied input"