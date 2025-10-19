/**
 * @name Complete server-side request forgery vulnerability
 * @description Identifies HTTP requests where attackers can fully manipulate target URLs through user input,
 *              enabling SSRF attacks against internal infrastructure
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
  // Malicious input entry point controlled by attacker
  FullServerSideRequestForgeryFlow::PathNode maliciousInputSource,
  // Vulnerable HTTP request endpoint
  FullServerSideRequestForgeryFlow::PathNode vulnerableSink,
  // Target HTTP client operation
  Http::Client::Request request
where
  // Establish data flow path from source to sink
  FullServerSideRequestForgeryFlow::flowPath(maliciousInputSource, vulnerableSink) and
  // Verify complete URL control by untrusted input
  fullyControlledRequest(request) and
  // Correlate sink with actual HTTP request
  request = vulnerableSink.getNode().(Sink).getRequest()
select
  // Vulnerability details with propagation path
  request, maliciousInputSource, vulnerableSink,
  // Attack impact description
  "Complete URL controlled by $@.", maliciousInputSource.getNode(),
  "untrusted user input"