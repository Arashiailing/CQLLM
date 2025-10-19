/**
 * @name Partial server-side request forgery
 * @description Identifies HTTP requests where URL segments are constructed using user-supplied data,
 *              potentially allowing attackers to manipulate request destinations
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
// Import SSRF vulnerability detection capabilities
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import partial SSRF data flow path tracking
import PartialServerSideRequestForgeryFlow::PathGraph

// Locate HTTP client requests with user-influenced URL components
from
  PartialServerSideRequestForgeryFlow::PathNode dataOriginNode,  // Starting point of untrusted data flow
  PartialServerSideRequestForgeryFlow::PathNode dataSinkNode,    // Endpoint where untrusted data is consumed
  Http::Client::Request httpRequest                              // Target HTTP request under analysis
where
  // Ensure the HTTP request corresponds to the identified sink
  httpRequest = dataSinkNode.getNode().(Sink).getRequest() and
  // Validate that a data flow path exists from source to sink
  PartialServerSideRequestForgeryFlow::flowPath(dataOriginNode, dataSinkNode) and
  // Filter out requests where the entire URL is controlled by user input
  not fullyControlledRequest(httpRequest)
select httpRequest, dataOriginNode, dataSinkNode, "URL component in this request originates from $@.", dataOriginNode.getNode(),
  "user-provided input"