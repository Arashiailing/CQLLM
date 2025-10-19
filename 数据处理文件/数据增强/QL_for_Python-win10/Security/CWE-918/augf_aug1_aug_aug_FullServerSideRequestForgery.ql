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

// Import core Python analysis capabilities
import python
// Import SSRF vulnerability detection framework
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import path tracking infrastructure for SSRF analysis
import FullServerSideRequestForgeryFlow::PathGraph

// Identify SSRF vulnerability paths with improved variable semantics
from
  // Source of untrusted user-controlled data
  FullServerSideRequestForgeryFlow::PathNode untrustedSource,
  // Sink where tainted data reaches HTTP request handler
  FullServerSideRequestForgeryFlow::PathNode vulnerableSink,
  // HTTP client request vulnerable to SSRF exploitation
  Http::Client::Request vulnerableRequest
where
  // Establish connection between sink node and actual HTTP request
  vulnerableRequest = vulnerableSink.getNode().(Sink).getRequest()
  and
  // Verify complete external control over request URL
  fullyControlledRequest(vulnerableRequest)
  and
  // Confirm data flow propagation from source to sink
  FullServerSideRequestForgeryFlow::flowPath(untrustedSource, vulnerableSink)
select
  // Report vulnerable request with complete flow path
  vulnerableRequest, untrustedSource, vulnerableSink,
  // Generate contextual vulnerability description
  "Complete URL controlled by $@.", untrustedSource.getNode(),
  "untrusted user input"