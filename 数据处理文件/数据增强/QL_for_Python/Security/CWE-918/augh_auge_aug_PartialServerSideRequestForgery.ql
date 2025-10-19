/**
 * @name Partial server-side request forgery
 * @description Identifies potential SSRF vulnerabilities where user input influences parts of a URL
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

// Detect HTTP requests with URL components derived from untrusted user input
from
  PartialServerSideRequestForgeryFlow::PathNode untrustedDataSource, // Entry point of untrusted data
  PartialServerSideRequestForgeryFlow::PathNode vulnerableSink,      // Point where data is used in request
  Http::Client::Request targetRequest                                // The HTTP request under analysis
where
  // Establish relationship between the sink and the HTTP request
  targetRequest = vulnerableSink.getNode().(Sink).getRequest()
  and
  // Confirm data flows from untrusted source to the vulnerable sink
  PartialServerSideRequestForgeryFlow::flowPath(untrustedDataSource, vulnerableSink)
  and
  // Filter out requests where the entire URL is controlled by user input
  not fullyControlledRequest(targetRequest)
select targetRequest, untrustedDataSource, vulnerableSink, "URL component in this request originates from $@.", untrustedDataSource.getNode(),
  "user-provided input"