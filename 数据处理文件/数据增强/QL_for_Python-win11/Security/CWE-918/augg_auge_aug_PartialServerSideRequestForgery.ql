/**
 * @name Partial server-side request forgery
 * @description Identifies HTTP requests where URL components are derived from user input, potentially enabling request forgery attacks
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import Python standard library
import python
// Import SSRF detection utilities
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import partial SSRF flow path graph
import PartialServerSideRequestForgeryFlow::PathGraph

// Identify vulnerable HTTP requests with tainted URL components
from
  PartialServerSideRequestForgeryFlow::PathNode taintedSource,  // Origin of untrusted data
  PartialServerSideRequestForgeryFlow::PathNode vulnerableSink,  // Destination where tainted data is used
  Http::Client::Request request                                  // HTTP request being analyzed
where
  // Correlate request with sink location
  request = vulnerableSink.getNode().(Sink).getRequest() and
  // Verify data flow path from source to sink
  PartialServerSideRequestForgeryFlow::flowPath(taintedSource, vulnerableSink) and
  // Exclude requests with fully controlled URLs
  not fullyControlledRequest(request)
select request, taintedSource, vulnerableSink, "URL component in this request originates from $@.", taintedSource.getNode(),
  "user-provided input"