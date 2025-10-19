/**
 * @name Full server-side request forgery
 * @description Detects network requests to URLs that are fully controlled by user input, enabling request forgery attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/full-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Core Python language support
import python
// SSRF vulnerability detection dataflow module
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Path graph implementation for SSRF flows
import FullServerSideRequestForgeryFlow::PathGraph

// Identify vulnerable HTTP requests with user-controlled URLs
from
  // Origin node representing user-controlled input
  FullServerSideRequestForgeryFlow::PathNode originNode,
  // Target node representing HTTP request construction
  FullServerSideRequestForgeryFlow::PathNode targetNode,
  // HTTP client request being analyzed
  Http::Client::Request httpRequest
where
  // Associate HTTP request with sink node
  httpRequest = targetNode.getNode().(Sink).getRequest()
  // Verify data flow path from user input to request
  and FullServerSideRequestForgeryFlow::flowPath(originNode, targetNode)
  // Confirm complete user control over request URL
  and fullyControlledRequest(httpRequest)
select
  // Vulnerable HTTP request instance
  httpRequest,
  // Source of user-controlled input
  originNode,
  // Destination where tainted data is used
  targetNode,
  // Alert message with vulnerability details
  "The full URL of this request depends on a $@.", originNode.getNode(),
  "user-provided value"