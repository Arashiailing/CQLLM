/**
 * @name URL redirection from remote source
 * @description Detects URL redirection vulnerabilities where unvalidated user input
 *              can redirect users to malicious websites, enabling phishing attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity low
 * @id py/url-redirection
 * @tags security
 *       external/cwe/cwe-601
 * @precision high
 */

// Core Python analysis libraries
import python

// Security dataflow analysis for URL redirection
import semmle.python.security.dataflow.UrlRedirectQuery

// Path graph visualization module
import UrlRedirectFlow::PathGraph

// Identify vulnerable URL redirection paths
from UrlRedirectFlow::PathNode userInputNode, UrlRedirectFlow::PathNode redirectTargetNode
where 
  // Data flows from untrusted user input to redirect target
  UrlRedirectFlow::flowPath(userInputNode, redirectTargetNode)
select 
  // Vulnerable redirect location
  redirectTargetNode.getNode(), 
  // Complete dataflow path visualization
  userInputNode, redirectTargetNode, 
  // Security alert with source annotation
  "Untrusted URL redirection depends on a $@.", 
  userInputNode.getNode(), 
  "user-provided value"