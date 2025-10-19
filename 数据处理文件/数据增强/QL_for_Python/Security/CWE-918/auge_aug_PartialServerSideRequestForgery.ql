/**
 * @name Partial server-side request forgery
 * @description Detects network requests where URL components are influenced by user input, enabling request forgery attacks
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import Python standard library
import python
// Import SSRF detection utilities
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import partial SSRF flow path graph
import PartialServerSideRequestForgeryFlow::PathGraph

// Identify vulnerable HTTP requests with user-controlled URL components
from
  PartialServerSideRequestForgeryFlow::PathNode sourceNode, // Origin of untrusted data
  PartialServerSideRequestForgeryFlow::PathNode sinkNode,   // Destination where data is used
  Http::Client::Request httpRequest                        // HTTP request being analyzed
where
  // Ensure the request matches the sink location
  httpRequest = sinkNode.getNode().(Sink).getRequest() and
  // Verify data flow path exists from source to sink
  PartialServerSideRequestForgeryFlow::flowPath(sourceNode, sinkNode) and
  // Exclude requests with fully controlled URLs
  not fullyControlledRequest(httpRequest)
select httpRequest, sourceNode, sinkNode, "URL component in this request originates from $@.", sourceNode.getNode(),
  "user-provided input"