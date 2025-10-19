/**
 * @name URL redirection from remote source
 * @description Detects security vulnerabilities in web applications where users are
 *              redirected to external URLs based on unvalidated user input. This can
 *              lead to phishing attacks by redirecting users to malicious websites.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity low
 * @id py/url-redirection
 * @tags security
 *       external/cwe/cwe-601
 * @precision high
 */

// Import core Python analysis capabilities
import python

// Import specialized dataflow analysis for detecting URL redirection vulnerabilities
import semmle.python.security.dataflow.UrlRedirectQuery

// Import path graph visualization for tracking and visualizing data flow paths
import UrlRedirectFlow::PathGraph

// Define source and sink nodes for URL redirection vulnerability detection
from UrlRedirectFlow::PathNode maliciousSourceNode, UrlRedirectFlow::PathNode targetRedirectSink
where 
  // Establish data flow relationship between untrusted input and redirect target
  UrlRedirectFlow::flowPath(maliciousSourceNode, targetRedirectSink)
select 
  // Identify the vulnerable redirect location in the code
  targetRedirectSink.getNode(), 
  // Provide complete data flow path for vulnerability visualization
  maliciousSourceNode, targetRedirectSink, 
  // Generate security alert with source annotation
  "Untrusted URL redirection depends on a $@.", 
  maliciousSourceNode.getNode(), 
  "user-provided value"