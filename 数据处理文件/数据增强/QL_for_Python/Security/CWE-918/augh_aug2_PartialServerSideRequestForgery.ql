/**
 * @name Partial server-side request forgery
 * @description Identifies network requests where URLs incorporate user-controlled input,
 *              potentially allowing attackers to manipulate request destinations (SSRF attacks).
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import standard Python language analysis module
import python
// Import SSRF (Server-Side Request Forgery) security data flow analysis
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import partial SSRF flow path graph for tracking data propagation
import PartialServerSideRequestForgeryFlow::PathGraph

// Identify partial SSRF vulnerabilities by tracking tainted data flow
from
  PartialServerSideRequestForgeryFlow::PathNode userControlledSource,  // User-controlled input source
  PartialServerSideRequestForgeryFlow::PathNode taintedSink,           // HTTP request destination
  Http::Client::Request vulnerableRequest                              // The vulnerable HTTP request
where
  // Verify the HTTP request is associated with the sink node
  vulnerableRequest = taintedSink.getNode().(Sink).getRequest() and
  // Confirm data flows from source to sink creating a vulnerability path
  PartialServerSideRequestForgeryFlow::flowPath(userControlledSource, taintedSink) and
  // Ensure the request is not completely controlled by the application (partial control only)
  not fullyControlledRequest(vulnerableRequest)
select vulnerableRequest, userControlledSource, taintedSink, "Part of the URL of this request depends on a $@.", userControlledSource.getNode(),
  "user-provided value"