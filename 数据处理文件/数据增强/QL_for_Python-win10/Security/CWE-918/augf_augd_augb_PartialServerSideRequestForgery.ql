/**
 * @name Partial server-side request forgery
 * @description Identifies network requests where URL components are constructed from untrusted user input,
 *              allowing attackers to influence server-side requests.
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

// Identify data flow paths indicating partial SSRF vulnerabilities
from
  Http::Client::Request outboundHttpRequest,                      // Outbound HTTP request under analysis
  PartialServerSideRequestForgeryFlow::PathNode untrustedDataSource,  // Origin of untrusted user input
  PartialServerSideRequestForgeryFlow::PathNode vulnerableRequestSink  // Location where tainted data reaches HTTP request
where
  // Connect the HTTP request to the vulnerability sink
  outboundHttpRequest = vulnerableRequestSink.getNode().(Sink).getRequest() and
  // Verify the request is not entirely controlled by the application
  not fullyControlledRequest(outboundHttpRequest) and
  // Confirm data flows from untrusted input to the vulnerable request
  PartialServerSideRequestForgeryFlow::flowPath(untrustedDataSource, vulnerableRequestSink)
select outboundHttpRequest, untrustedDataSource, vulnerableRequestSink, "Part of the URL of this request depends on a $@.", untrustedDataSource.getNode(),
  "user-provided value"