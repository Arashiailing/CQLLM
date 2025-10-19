/**
 * @name URL redirection from remote source
 * @description Identifies security vulnerabilities where web applications redirect users
 *              to external URLs based on unvalidated user input, potentially enabling
 *              phishing attacks by redirecting to malicious sites.
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

// Import specialized dataflow analysis for URL redirection vulnerabilities
import semmle.python.security.dataflow.UrlRedirectQuery

// Import path graph visualization for tracking data flow
import UrlRedirectFlow::PathGraph

// Define the source and sink nodes for URL redirection vulnerability detection
from UrlRedirectFlow::PathNode untrustedInputNode, UrlRedirectFlow::PathNode vulnerableRedirectNode
where 
  // Establish data flow relationship between untrusted input and redirect target
  UrlRedirectFlow::flowPath(untrustedInputNode, vulnerableRedirectNode)
select 
  // Identify the vulnerable redirect location in the code
  vulnerableRedirectNode.getNode(), 
  // Provide complete data flow path for vulnerability visualization
  untrustedInputNode, vulnerableRedirectNode, 
  // Generate security alert with source annotation
  "Untrusted URL redirection depends on a $@.", 
  untrustedInputNode.getNode(), 
  "user-provided value"