/**
 * @name Partial server-side request forgery
 * @description Detects when a network request contains URL components derived from untrusted user input,
 *              enabling attackers to manipulate server-side requests.
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

// Analyze data flow paths to identify partial SSRF vulnerabilities
from
  Http::Client::Request httpClientRequest,                      // HTTP client request being analyzed
  PartialServerSideRequestForgeryFlow::PathNode untrustedInputSource,  // Entry point of untrusted user input
  PartialServerSideRequestForgeryFlow::PathNode requestVulnerabilitySink  // Point where tainted data reaches HTTP request
where
  // Establish connection between HTTP request and vulnerability sink
  httpClientRequest = requestVulnerabilitySink.getNode().(Sink).getRequest() and
  // Ensure data flows from untrusted input to the vulnerable request
  PartialServerSideRequestForgeryFlow::flowPath(untrustedInputSource, requestVulnerabilitySink) and
  // Verify the request contains at least some user-controlled components
  not fullyControlledRequest(httpClientRequest)
select httpClientRequest, untrustedInputSource, requestVulnerabilitySink, "Part of the URL of this request depends on a $@.", untrustedInputSource.getNode(),
  "user-provided value"