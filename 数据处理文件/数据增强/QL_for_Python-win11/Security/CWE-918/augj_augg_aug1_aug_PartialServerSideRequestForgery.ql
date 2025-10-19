/**
 * @name Partial server-side request forgery
 * @description Identifies HTTP requests with URL components derived from untrusted sources,
 *              which may lead to server-side request forgery vulnerabilities
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import Python language support
import python
// Import SSRF detection capabilities
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import partial SSRF analysis path graph
import PartialServerSideRequestForgeryFlow::PathGraph

// Locate HTTP requests containing vulnerable URL components
from
  PartialServerSideRequestForgeryFlow::PathNode originNode,      // Starting point of untrusted data
  PartialServerSideRequestForgeryFlow::PathNode destinationNode, // Final destination of data flow
  Http::Client::Request httpRequest                              // HTTP request being analyzed
where
  // Establish data flow connection between source and sink
  PartialServerSideRequestForgeryFlow::flowPath(originNode, destinationNode) and
  // Correlate HTTP request with the sink location
  httpRequest = destinationNode.getNode().(Sink).getRequest() and
  // Filter out requests with completely user-controlled URLs
  not fullyControlledRequest(httpRequest)
select httpRequest, originNode, destinationNode, "URL component in this request originates from $@.", originNode.getNode(),
  "user-provided input"