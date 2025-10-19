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

// This query detects potential SSRF vulnerabilities where user-controlled input
// influences only parts of a URL rather than the entire URL. Such partial control
// can still lead to server-side request forgery attacks.
from
  PartialServerSideRequestForgeryFlow::PathNode untrustedSource,  // Entry point of untrusted data
  PartialServerSideRequestForgeryFlow::PathNode requestSink,      // Point where data is used in request
  Http::Client::Request httpRequest                              // The HTTP request under analysis
where
  // Establish connection between the sink and the HTTP request
  httpRequest = requestSink.getNode().(Sink).getRequest()
  and
  // Verify data flows from untrusted source to the vulnerable sink
  PartialServerSideRequestForgeryFlow::flowPath(untrustedSource, requestSink)
  and
  // Exclude requests where the entire URL is controlled by user input
  not fullyControlledRequest(httpRequest)
select httpRequest, untrustedSource, requestSink, "URL component in this request originates from $@.", untrustedSource.getNode(),
  "user-provided input"