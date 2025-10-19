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

// Identify SSRF vulnerability paths with enhanced variable naming
from
  // Origin point of user-controlled data
  FullServerSideRequestForgeryFlow::PathNode taintedSource,
  // Destination point where tainted data reaches HTTP request
  FullServerSideRequestForgeryFlow::PathNode requestSink,
  // HTTP client request susceptible to SSRF
  Http::Client::Request compromisedRequest
where
  // Link sink node to actual HTTP request
  compromisedRequest = requestSink.getNode().(Sink).getRequest() and
  // Verify complete user control over request URL
  fullyControlledRequest(compromisedRequest) and
  // Trace data flow from source to sink
  FullServerSideRequestForgeryFlow::flowPath(taintedSource, requestSink)
select
  // Report vulnerable request and flow path
  compromisedRequest, taintedSource, requestSink,
  // Generate vulnerability description
  "Complete URL controlled by $@.", taintedSource.getNode(),
  "untrusted user input"