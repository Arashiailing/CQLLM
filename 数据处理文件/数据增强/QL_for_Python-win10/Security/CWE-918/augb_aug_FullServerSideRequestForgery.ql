/**
 * @name Complete server-side request forgery vulnerability
 * @description Identifies HTTP requests where attackers can fully control the target URL through user input,
 *              enabling server-side request forgery attacks against internal systems.
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
  FullServerSideRequestForgeryFlow::PathNode untrustedDataSource,
  // Vulnerable HTTP request destination
  FullServerSideRequestForgeryFlow::PathNode vulnerableSink,
  // Target HTTP client operation
  Http::Client::Request requestObj
where
  // Verify data propagation path from source to sink
  FullServerSideRequestForgeryFlow::flowPath(untrustedDataSource, vulnerableSink) and
  // Associate sink with actual HTTP request
  requestObj = vulnerableSink.getNode().(Sink).getRequest() and
  // Confirm complete URL control by untrusted input
  fullyControlledRequest(requestObj)
select
  // Vulnerability details with propagation path
  requestObj, untrustedDataSource, vulnerableSink,
  // Attack impact description
  "Complete URL controlled by $@.", untrustedDataSource.getNode(),
  "untrusted user input"