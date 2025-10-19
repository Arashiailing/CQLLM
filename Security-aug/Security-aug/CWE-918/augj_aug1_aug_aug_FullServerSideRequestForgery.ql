/**
 * @name Complete server-side request forgery vulnerability
 * @description Identifies HTTP requests where the entire URL is derived from untrusted external input, creating SSRF attack vectors
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/full-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import core Python analysis capabilities
import python
// Import SSRF vulnerability detection framework
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import path tracking for SSRF data flows
import FullServerSideRequestForgeryFlow::PathGraph

// Identify complete SSRF vulnerability paths
from
  // Origin point of untrusted user-controlled data
  FullServerSideRequestForgeryFlow::PathNode untrustedSource,
  // Destination point where tainted data reaches HTTP request
  FullServerSideRequestForgeryFlow::PathNode ssrfSink,
  // HTTP client request vulnerable to SSRF exploitation
  Http::Client::Request vulnerableRequest
where
  // Establish connection between sink node and actual HTTP request
  vulnerableRequest = ssrfSink.getNode().(Sink).getRequest()
  and
  // Verify complete external control over request URL
  fullyControlledRequest(vulnerableRequest)
  and
  // Confirm data flow propagation from source to sink
  FullServerSideRequestForgeryFlow::flowPath(untrustedSource, ssrfSink)
select
  // Report vulnerable request with complete flow path
  vulnerableRequest, untrustedSource, ssrfSink,
  // Generate vulnerability description message
  "Complete URL controlled by $@.", untrustedSource.getNode(),
  "untrusted user input"