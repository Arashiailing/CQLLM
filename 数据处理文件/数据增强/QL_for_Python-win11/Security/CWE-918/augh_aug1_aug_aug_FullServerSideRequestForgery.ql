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
  // Origin point of untrusted external input
  FullServerSideRequestForgeryFlow::PathNode untrustedSource,
  // Destination point where tainted data reaches HTTP request
  FullServerSideRequestForgeryFlow::PathNode vulnerableSink,
  // HTTP client request susceptible to SSRF
  Http::Client::Request affectedRequest
where
  // Associate sink node with actual HTTP request
  affectedRequest = vulnerableSink.getNode().(Sink).getRequest()
  // Verify complete external control over request URL
  and fullyControlledRequest(affectedRequest)
  // Trace data flow from source to sink
  and FullServerSideRequestForgeryFlow::flowPath(untrustedSource, vulnerableSink)
select
  // Report vulnerable request and flow path
  affectedRequest, untrustedSource, vulnerableSink,
  // Generate vulnerability description
  "Complete URL controlled by $@.", untrustedSource.getNode(),
  "untrusted user input"