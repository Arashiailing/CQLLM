/**
 * @name Partial server-side request forgery
 * @description Identifies network requests where URL components are influenced by untrusted user input, potentially enabling request forgery attacks
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

// Detect vulnerable HTTP requests containing user-controlled URL components
from
  PartialServerSideRequestForgeryFlow::PathNode sourceNode, // Origin of untrusted data
  PartialServerSideRequestForgeryFlow::PathNode sinkNode,   // Destination where data is used
  Http::Client::Request httpRequest                         // HTTP request being analyzed
where
  // Ensure the request corresponds to the sink node
  httpRequest = sinkNode.getNode().(Sink).getRequest() and
  // Filter out requests with entirely controlled URLs
  not fullyControlledRequest(httpRequest) and
  // Validate that a data flow path exists from source to sink
  PartialServerSideRequestForgeryFlow::flowPath(sourceNode, sinkNode)
select httpRequest, sourceNode, sinkNode, "URL component in this request originates from $@.", sourceNode.getNode(),
  "user-provided input"