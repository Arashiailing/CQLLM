/**
 * @name Partial server-side request forgery
 * @description Detects HTTP requests where URL elements are tainted by untrusted user input,
 *              which could lead to server-side request forgery vulnerabilities
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import Python language support
import python
// Import SSRF security analysis framework
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import partial SSRF data flow path analysis
import PartialServerSideRequestForgeryFlow::PathGraph

// Define the core vulnerability pattern: HTTP requests with user-controlled URL components
from
  Http::Client::Request targetRequest,                          // Target HTTP request for analysis
  PartialServerSideRequestForgeryFlow::PathNode taintedSource,  // Entry point of untrusted data
  PartialServerSideRequestForgeryFlow::PathNode vulnerableSink  // Point where data is used in request
where
  // Verify data flow path exists from source to sink
  PartialServerSideRequestForgeryFlow::flowPath(taintedSource, vulnerableSink) and
  // Establish relationship between HTTP request and sink node
  targetRequest = vulnerableSink.getNode().(Sink).getRequest() and
  // Filter out requests with entirely controlled URLs to focus on partial SSRF
  not fullyControlledRequest(targetRequest)
select targetRequest, taintedSource, vulnerableSink, "URL component in this request originates from $@.", taintedSource.getNode(),
  "user-provided input"