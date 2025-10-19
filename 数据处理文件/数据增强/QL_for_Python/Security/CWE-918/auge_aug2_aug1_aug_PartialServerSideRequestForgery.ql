/**
 * @name Partial server-side request forgery
 * @description Identifies network requests where URL components are constructed using external input,
 *              which could lead to server-side request forgery vulnerabilities
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
import PartialServerSideRequestForgeryFlow::PathGraph

from
  PartialServerSideRequestForgeryFlow::PathNode entryNode,      // Source of untrusted data flow
  PartialServerSideRequestForgeryFlow::PathNode consumptionNode, // Destination where data is used
  Http::Client::Request httpRequest                          // Target HTTP request under analysis
where
  // Verify the request corresponds to the sink location in data flow
  httpRequest = consumptionNode.getNode().(Sink).getRequest() and
  // Ensure data flows from source to sink
  PartialServerSideRequestForgeryFlow::flowPath(entryNode, consumptionNode) and
  // Exclude requests where entire URL is user-controlled
  not fullyControlledRequest(httpRequest)
select httpRequest, entryNode, consumptionNode, "URL component in this request originates from $@.", entryNode.getNode(),
  "user-provided input"