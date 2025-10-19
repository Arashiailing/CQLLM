/**
 * @name URL Redirection from Remote Source
 * @description Detects URL redirections based on unvalidated user input,
 *              potentially leading to malicious website redirections.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity low
 * @id py/url-redirection
 * @tags security
 *       external/cwe/cwe-601
 * @precision high
 */

// Import core Python analysis libraries
import python

// Import security data flow modules for URL redirection analysis
import semmle.python.security.dataflow.UrlRedirectQuery

// Import path graph representation for vulnerability flow tracking
import UrlRedirectFlow::PathGraph

// Identify vulnerable URL redirection paths
from UrlRedirectFlow::PathNode inputSource, UrlRedirectFlow::PathNode redirectTarget
where 
  // Ensure data flow exists between untrusted input and redirection point
  UrlRedirectFlow::flowPath(inputSource, redirectTarget)
select 
  // Primary result: vulnerable redirection location
  redirectTarget.getNode(),
  // Path components for visualization
  inputSource, 
  redirectTarget,
  // Alert message with source reference
  "Untrusted URL redirection depends on a $@.",
  // Source node reference for message parameter
  inputSource.getNode(),
  // Source description
  "user-provided value"