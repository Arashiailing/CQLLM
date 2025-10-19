/**
 * @name Complete server-side request forgery
 * @description Detects network requests to URLs entirely controlled by user input, enabling request forgery attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/full-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import Python core libraries
import python
// Import SSRF detection module
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import path visualization component
import FullServerSideRequestForgeryFlow::PathGraph

from
  // Origin point of untrusted data
  FullServerSideRequestForgeryFlow::PathNode origin,
  // Destination point where data is used
  FullServerSideRequestForgeryFlow::PathNode destination,
  // HTTP request object
  Http::Client::Request httpRequest
where
  // Verify data flow path exists
  FullServerSideRequestForgeryFlow::flowPath(origin, destination) and
  // Match request with sink node
  httpRequest = destination.getNode().(Sink).getRequest() and
  // Confirm complete user control
  fullyControlledRequest(httpRequest)
select 
  // Output core components
  httpRequest, origin, destination,
  // Alert message with vulnerability context
  "The complete URL of this request is derived from a $@.", origin.getNode(),
  "user-controlled input"