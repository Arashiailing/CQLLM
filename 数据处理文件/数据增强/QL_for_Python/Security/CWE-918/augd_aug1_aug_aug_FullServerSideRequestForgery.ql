/**
 * @name Complete server-side request forgery vulnerability
 * @description Identifies HTTP requests where attackers fully control the target URL, enabling SSRF attacks
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
  // Entry point of untrusted data from external sources
  FullServerSideRequestForgeryFlow::PathNode untrustedDataSource,
  // Point where untrusted data flows into an HTTP request sink
  FullServerSideRequestForgeryFlow::PathNode vulnerableSink,
  // HTTP client request that is vulnerable to SSRF
  Http::Client::Request affectedHttpRequest
where
  // Associate sink node with actual HTTP request
  affectedHttpRequest = vulnerableSink.getNode().(Sink).getRequest() and
  // Verify complete attacker control over request URL
  fullyControlledRequest(affectedHttpRequest) and
  // Trace data flow path from source to sink
  FullServerSideRequestForgeryFlow::flowPath(untrustedDataSource, vulnerableSink)
select
  // Report vulnerable request and flow path
  affectedHttpRequest, untrustedDataSource, vulnerableSink,
  // Generate vulnerability description
  "Complete URL controlled by $@.", untrustedDataSource.getNode(),
  "untrusted user input"