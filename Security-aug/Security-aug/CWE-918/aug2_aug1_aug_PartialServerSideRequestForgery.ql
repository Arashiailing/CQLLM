/**
 * @name Partial server-side request forgery
 * @description Detects network requests where URL components are influenced by external input,
 *              potentially enabling server-side request forgery attacks
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
  PartialServerSideRequestForgeryFlow::PathNode sourceNode,       // Entry point of untrusted data flow
  PartialServerSideRequestForgeryFlow::PathNode sinkNode,         // Location where data is consumed
  Http::Client::Request clientRequest                          // Target HTTP request being analyzed
where
  // Verify the request matches the sink location in data flow
  clientRequest = sinkNode.getNode().(Sink).getRequest() and
  // Confirm existence of data flow path from source to sink
  PartialServerSideRequestForgeryFlow::flowPath(sourceNode, sinkNode) and
  // Exclude cases where entire URL is controlled by user input
  not fullyControlledRequest(clientRequest)
select clientRequest, sourceNode, sinkNode, "URL component in this request originates from $@.", sourceNode.getNode(),
  "user-provided input"