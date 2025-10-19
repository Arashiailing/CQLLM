/**
 * @name Complete server-side request forgery vulnerability
 * @description Detects HTTP requests where attackers fully control target URLs via user input,
 *              enabling SSRF attacks against internal systems
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/full-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Core Python analysis framework
import python
// SSRF vulnerability detection capabilities
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Path tracking for vulnerability propagation
import FullServerSideRequestForgeryFlow::PathGraph

from
  // Entry point for attacker-controlled data
  FullServerSideRequestForgeryFlow::PathNode maliciousInputSource,
  // Destination point for vulnerable HTTP requests
  FullServerSideRequestForgeryFlow::PathNode vulnerableRequestSink,
  // Target HTTP client operation being exploited
  Http::Client::Request targetHttpRequest
where
  // Verify the entire URL is controlled by untrusted input
  fullyControlledRequest(targetHttpRequest) and
  // Map the sink to its corresponding HTTP request
  targetHttpRequest = vulnerableRequestSink.getNode().(Sink).getRequest() and
  // Confirm data flow path from source to sink exists
  FullServerSideRequestForgeryFlow::flowPath(maliciousInputSource, vulnerableRequestSink)
select
  // Vulnerability details with propagation path
  targetHttpRequest, maliciousInputSource, vulnerableRequestSink,
  // Attack impact description
  "Complete URL controlled by $@.", maliciousInputSource.getNode(),
  "untrusted user input"