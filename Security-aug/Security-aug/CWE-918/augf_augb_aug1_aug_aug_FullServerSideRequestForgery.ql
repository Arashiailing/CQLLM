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

// Identify complete SSRF vulnerability paths through tainted data flow
from
  // Source of untrusted user input
  FullServerSideRequestForgeryFlow::PathNode taintedSource,
  // Sink where tainted data reaches HTTP request
  FullServerSideRequestForgeryFlow::PathNode requestSink,
  // Vulnerable HTTP client request
  Http::Client::Request controlledRequest
where
  // Establish data flow path from source to sink
  FullServerSideRequestForgeryFlow::flowPath(taintedSource, requestSink) and
  // Verify complete user control over request URL
  fullyControlledRequest(controlledRequest) and
  // Map sink node to actual HTTP request
  controlledRequest = requestSink.getNode().(Sink).getRequest()
select
  // Report vulnerable request and flow path
  controlledRequest, taintedSource, requestSink,
  // Generate vulnerability description
  "Complete URL controlled by $@.", taintedSource.getNode(),
  "untrusted user input"