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
  // Attacker-controlled data entry point
  FullServerSideRequestForgeryFlow::PathNode attackerControlledSource,
  // Vulnerable HTTP request destination
  FullServerSideRequestForgeryFlow::PathNode unsafeSink,
  // Target HTTP client operation
  Http::Client::Request httpRequest
where
  // Verify complete URL control by untrusted input
  fullyControlledRequest(httpRequest) and
  // Associate sink with actual HTTP request
  httpRequest = unsafeSink.getNode().(Sink).getRequest() and
  // Confirm data propagation path from source to sink
  FullServerSideRequestForgeryFlow::flowPath(attackerControlledSource, unsafeSink)
select
  // Vulnerability details with propagation path
  httpRequest, attackerControlledSource, unsafeSink,
  // Attack impact description
  "Complete URL controlled by $@.", attackerControlledSource.getNode(),
  "untrusted user input"