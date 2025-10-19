/**
 * @name Partial server-side request forgery
 * @description Identifies potential SSRF vulnerabilities where user-controlled input
 *              partially influences the destination URL of network requests, allowing
 *              attackers to manipulate request targets.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import the standard Python analysis framework
import python
// Import SSRF (Server-Side Request Forgery) data flow analysis components
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import the partial SSRF flow path graph for vulnerability tracking
import PartialServerSideRequestForgeryFlow::PathGraph

// Detect partial SSRF vulnerabilities by analyzing data flow paths
from
  PartialServerSideRequestForgeryFlow::PathNode userInputSource,  // Source of user-controllable data
  PartialServerSideRequestForgeryFlow::PathNode requestSink,       // Destination of tainted data in HTTP request
  Http::Client::Request httpRequest                                // The vulnerable network request being analyzed
where
  // Establish relationship between the HTTP request and the sink node
  httpRequest = requestSink.getNode().(Sink).getRequest() and
  
  // Verify that tainted data flows from the user input source to the request sink
  PartialServerSideRequestForgeryFlow::flowPath(userInputSource, requestSink) and
  
  // Exclude requests that are fully controlled by the application (partial control only)
  not fullyControlledRequest(httpRequest)
  
select httpRequest, userInputSource, requestSink, "Part of the URL of this request depends on a $@.", userInputSource.getNode(),
  "user-provided value"