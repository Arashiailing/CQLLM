/**
 * @name Partial server-side request forgery
 * @description Making a network request to a URL that is partially user-controlled allows for request forgery attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import core Python language analysis library
import python
// Import SSRF (Server-Side Request Forgery) security data flow analysis module
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import path graph representation for partial SSRF vulnerability tracking
import PartialServerSideRequestForgeryFlow::PathGraph

// Identify partial SSRF vulnerabilities by analyzing data flow paths
from
  PartialServerSideRequestForgeryFlow::PathNode taintedSource,  // Entry point of untrusted user input
  PartialServerSideRequestForgeryFlow::PathNode vulnerableSink,  // Point where tainted data reaches HTTP request
  Http::Client::Request networkRequest                           // HTTP client request being analyzed
where
  // Associate the HTTP request with the vulnerable sink point
  networkRequest = vulnerableSink.getNode().(Sink).getRequest() and
  // Verify existence of data flow from tainted source to vulnerable sink
  PartialServerSideRequestForgeryFlow::flowPath(taintedSource, vulnerableSink) and
  // Confirm the request is not completely controlled by the application
  not fullyControlledRequest(networkRequest)
select networkRequest, taintedSource, vulnerableSink, "Part of the URL of this request depends on a $@.", taintedSource.getNode(),
  "user-provided value"