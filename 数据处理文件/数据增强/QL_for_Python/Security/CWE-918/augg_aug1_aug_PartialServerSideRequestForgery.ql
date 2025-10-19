/**
 * @name Partial server-side request forgery
 * @description Detects HTTP requests where URL components are influenced by untrusted input,
 *              potentially creating server-side request forgery vulnerabilities
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
// Import SSRF vulnerability detection utilities
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import partial SSRF flow analysis path graph
import PartialServerSideRequestForgeryFlow::PathGraph

// Identify HTTP requests with vulnerable URL components influenced by external input
from
  PartialServerSideRequestForgeryFlow::PathNode sourceNode,       // Origin of untrusted data flow
  PartialServerSideRequestForgeryFlow::PathNode sinkNode,          // Endpoint where data is used
  Http::Client::Request requestObj                                // Target HTTP request
where
  // Verify data flow path exists from source to sink
  PartialServerSideRequestForgeryFlow::flowPath(sourceNode, sinkNode) and
  // Ensure analyzed request matches the sink location
  requestObj = sinkNode.getNode().(Sink).getRequest() and
  // Exclude requests where entire URL is user-controlled
  not fullyControlledRequest(requestObj)
select requestObj, sourceNode, sinkNode, "URL component in this request originates from $@.", sourceNode.getNode(),
  "user-provided input"