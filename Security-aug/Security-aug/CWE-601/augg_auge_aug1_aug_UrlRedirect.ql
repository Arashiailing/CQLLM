/**
 * @name URL redirection from remote source
 * @description Detects security issues where web applications perform redirects
 *              to external locations using unvalidated user-supplied data, which could
 *              facilitate phishing attacks by directing users to harmful websites.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity low
 * @id py/url-redirection
 * @tags security
 *       external/cwe/cwe-601
 * @precision high
 */

// Import fundamental Python analysis functionality
import python

// Import specialized data flow analysis for identifying URL redirection vulnerabilities
import semmle.python.security.dataflow.UrlRedirectQuery

// Import path graph visualization capabilities for tracking data flow paths
import UrlRedirectFlow::PathGraph

// Define source and sink nodes for detecting URL redirection vulnerabilities
from UrlRedirectFlow::PathNode taintedSourceNode, UrlRedirectFlow::PathNode sinkRedirectNode
where 
  // Establish data flow connection between untrusted input and redirect destination
  UrlRedirectFlow::flowPath(taintedSourceNode, sinkRedirectNode)
select 
  // Identify the location of the vulnerable redirect in the code
  sinkRedirectNode.getNode(), 
  // Provide complete data flow path for vulnerability analysis
  taintedSourceNode, sinkRedirectNode, 
  // Generate security alert with source annotation
  "Untrusted URL redirection relies on a $@.", 
  taintedSourceNode.getNode(), 
  "user-provided value"