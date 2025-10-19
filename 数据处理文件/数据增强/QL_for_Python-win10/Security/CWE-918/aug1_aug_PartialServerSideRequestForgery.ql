/**
 * @name Partial server-side request forgery
 * @description Identifies network requests where URL elements are manipulated by user input, 
 *              potentially leading to server-side request forgery vulnerabilities
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import Python standard library modules
import python
// Import utilities for SSRF vulnerability detection
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import path graph for partial SSRF flow analysis
import PartialServerSideRequestForgeryFlow::PathGraph

// Identify HTTP requests with vulnerable URL components influenced by external input
from
  PartialServerSideRequestForgeryFlow::PathNode originNode,    // Starting point of untrusted data flow
  PartialServerSideRequestForgeryFlow::PathNode destinationNode, // Endpoint where data is utilized
  Http::Client::Request httpRequest                           // HTTP request under examination
where
  // Ensure the analyzed request corresponds to the sink location
  httpRequest = destinationNode.getNode().(Sink).getRequest() and
  // Validate that a data flow path exists from source to sink
  PartialServerSideRequestForgeryFlow::flowPath(originNode, destinationNode) and
  // Filter out requests where the entire URL is controlled by user input
  not fullyControlledRequest(httpRequest)
select httpRequest, originNode, destinationNode, "URL component in this request originates from $@.", originNode.getNode(),
  "user-provided input"