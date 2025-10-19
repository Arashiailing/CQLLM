/**
 * @name Partial server-side request forgery
 * @description Detects network requests made to URLs that are partially controlled by user input,
 *              which can lead to server-side request forgery vulnerabilities.
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
// Import SSRF (Server-Side Request Forgery) analysis module
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import the path graph class for partial SSRF flow analysis
import PartialServerSideRequestForgeryFlow::PathGraph

// Define the query to identify partial SSRF vulnerabilities
from
  PartialServerSideRequestForgeryFlow::PathNode originNode,  // Starting point of the data flow
  PartialServerSideRequestForgeryFlow::PathNode targetNode,   // Ending point of the data flow
  Http::Client::Request httpRequest                          // HTTP client request being analyzed
where
  // Verify that the HTTP request corresponds to the sink node
  httpRequest = targetNode.getNode().(Sink).getRequest() and
  
  // Check if there's a data flow path from the origin to the target
  PartialServerSideRequestForgeryFlow::flowPath(originNode, targetNode) and
  
  // Ensure the request is not fully controlled (only partially controlled)
  not fullyControlledRequest(httpRequest)
select 
  httpRequest, 
  originNode, 
  targetNode, 
  "Part of the URL of this request depends on a $@.", 
  originNode.getNode(),
  "user-provided value"