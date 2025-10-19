/**
 * @name Complete server-side request forgery vulnerability
 * @description Detects HTTP requests where the entire URL is controlled by external input, enabling SSRF attacks
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/full-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import required Python analysis modules
import python
// Import SSRF detection framework
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import path tracking for SSRF flows
import FullServerSideRequestForgeryFlow::PathGraph

// Identify SSRF vulnerability through user-controlled input flows
from
  // Entry point of untrusted data
  FullServerSideRequestForgeryFlow::PathNode userInputSource,
  // Destination point where tainted data reaches HTTP client
  FullServerSideRequestForgeryFlow::PathNode httpRequestSink,
  // Vulnerable HTTP request susceptible to SSRF
  Http::Client::Request ssrfVulnerableRequest
where
  // Map sink node to concrete HTTP request
  ssrfVulnerableRequest = httpRequestSink.getNode().(Sink).getRequest()
  and
  // Validate complete URL controllability
  fullyControlledRequest(ssrfVulnerableRequest)
  and
  // Trace data flow from source to sink
  FullServerSideRequestForgeryFlow::flowPath(userInputSource, httpRequestSink)
select
  // Report vulnerable request with flow path
  ssrfVulnerableRequest, userInputSource, httpRequestSink,
  // Generate vulnerability description
  "Complete URL controlled by $@.", userInputSource.getNode(),
  "untrusted user input"