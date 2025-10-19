/**
 * @name Complete server-side request forgery vulnerability
 * @description Detects when a network request is made to a URL that is entirely controlled by user input, enabling request forgery attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/full-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import necessary Python libraries
import python
// Import server-side request forgery analysis module
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import path graph for full SSRF tracking
import FullServerSideRequestForgeryFlow::PathGraph

// Define query components with enhanced variable naming
from
  // Source node representing the origin of user-controlled input
  FullServerSideRequestForgeryFlow::PathNode sourceNode,
  // Sink node representing the vulnerable HTTP request destination
  FullServerSideRequestForgeryFlow::PathNode sinkNode,
  // Vulnerable HTTP client request being analyzed
  Http::Client::Request vulnerableRequest
where
  // Verify the request matches the sink node's associated request
  vulnerableRequest = sinkNode.getNode().(Sink).getRequest() and
  // Confirm complete user control over the request URL
  fullyControlledRequest(vulnerableRequest) and
  // Establish data flow path from source to sink
  FullServerSideRequestForgeryFlow::flowPath(sourceNode, sinkNode)
select
  // Output the vulnerable request, source node, and sink node
  vulnerableRequest, sourceNode, sinkNode,
  // Generate vulnerability alert message
  "The complete URL of this request is derived from a $@.", sourceNode.getNode(),
  "user-controlled input"