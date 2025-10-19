/**
 * @name URL redirection from remote source
 * @description Detects potential security vulnerabilities where applications
 *              perform URL redirection based on unvalidated user input,
 *              which could lead to redirects to malicious websites.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity low
 * @id py/url-redirection
 * @tags security
 *       external/cwe/cwe-601
 * @precision high
 */

// Import Python language support for CodeQL analysis
import python

// Import security dataflow analysis module specifically for URL redirection detection
import semmle.python.security.dataflow.UrlRedirectQuery

// Import visualization module for dataflow path graphs
import UrlRedirectFlow::PathGraph

// Main query: Identify vulnerable URL redirection paths from untrusted sources
from UrlRedirectFlow::PathNode untrustedInputNode, UrlRedirectFlow::PathNode redirectionEndpointNode
where 
  // Verify that a dataflow path exists from untrusted input to redirection target
  UrlRedirectFlow::flowPath(untrustedInputNode, redirectionEndpointNode)
select 
  // Primary result: location of the redirection target
  redirectionEndpointNode.getNode(), 
  // Path visualization: source and sink nodes for the dataflow
  untrustedInputNode, redirectionEndpointNode, 
  // Description message highlighting the dependency on user input
  "Untrusted URL redirection depends on a $@.", 
  untrustedInputNode.getNode(), 
  "user-provided value"