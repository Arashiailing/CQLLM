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
  // Source node representing untrusted external input
  FullServerSideRequestForgeryFlow::PathNode untrustedDataSource,
  // Sink node where tainted data reaches HTTP client
  FullServerSideRequestForgeryFlow::PathNode vulnerableRequestSink,
  // Target HTTP request vulnerable to SSRF
  Http::Client::Request targetHttpRequest
where
  // Establish data flow path from source to sink
  FullServerSideRequestForgeryFlow::flowPath(untrustedDataSource, vulnerableRequestSink)
  and
  // Map sink node to concrete HTTP request
  targetHttpRequest = vulnerableRequestSink.getNode().(Sink).getRequest()
  and
  // Verify complete URL controllability condition
  fullyControlledRequest(targetHttpRequest)
select
  // Report vulnerable request with flow path
  targetHttpRequest, untrustedDataSource, vulnerableRequestSink,
  // Generate vulnerability description
  "Complete URL controlled by $@.", untrustedDataSource.getNode(),
  "untrusted user input"