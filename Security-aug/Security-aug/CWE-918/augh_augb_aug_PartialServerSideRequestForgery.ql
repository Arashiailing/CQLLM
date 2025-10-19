/**
 * @name Partial server-side request forgery
 * @description Detects network requests where URL segments are tainted by untrusted user input, potentially enabling server-side request forgery attacks
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import Python standard library modules
import python
// Import utilities for SSRF vulnerability detection
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import path graph for partial SSRF flow analysis
import PartialServerSideRequestForgeryFlow::PathGraph

// Identify HTTP requests with user-controlled URL components that could lead to SSRF
from
  PartialServerSideRequestForgeryFlow::PathNode untrustedDataSource, // Entry point of untrusted data
  PartialServerSideRequestForgeryFlow::PathNode vulnerableSink,     // Point where data is used in a request
  Http::Client::Request requestObj                                  // HTTP request under examination
where
  // Correlate the request with the sink node
  requestObj = vulnerableSink.getNode().(Sink).getRequest() and
  // Exclude requests where the entire URL is controlled by the application
  not fullyControlledRequest(requestObj) and
  // Confirm data flow from untrusted source to vulnerable sink
  PartialServerSideRequestForgeryFlow::flowPath(untrustedDataSource, vulnerableSink)
select requestObj, untrustedDataSource, vulnerableSink, "URL component in this request originates from $@.", untrustedDataSource.getNode(),
  "user-provided input"