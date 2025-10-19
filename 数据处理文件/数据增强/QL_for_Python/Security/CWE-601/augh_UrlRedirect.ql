/**
 * @name URL redirection from remote source
 * @description Detects potential security vulnerabilities where web applications
 *              perform URL redirections based on unvalidated user input, which
 *              could lead to open redirect attacks and phishing.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity low
 * @id py/url-redirection
 * @tags security
 *       external/cwe/cwe-601
 * @precision high
 */

// Import Python language support module for code analysis
import python

// Import specialized security data flow module for URL redirection analysis
import semmle.python.security.dataflow.UrlRedirectQuery

// Import path graph representation for tracking data flow paths
import UrlRedirectFlow::PathGraph

// Identify vulnerable URL redirection flows by analyzing data paths
from UrlRedirectFlow::PathNode originNode, UrlRedirectFlow::PathNode destinationNode
where UrlRedirectFlow::flowPath(originNode, destinationNode) // Filter for valid data flow paths
select destinationNode.getNode(), originNode, destinationNode, "Untrusted URL redirection depends on a $@.", originNode.getNode(),
  "user-provided value" // Output the sink, source path, and vulnerability details