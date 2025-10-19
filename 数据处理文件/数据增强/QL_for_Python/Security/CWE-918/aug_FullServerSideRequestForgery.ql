/**
 * @name Complete server-side request forgery vulnerability
 * @description Detects network requests where the entire URL is controlled by user input, enabling request forgery attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/full-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// Import required Python libraries
import python
// Import SSRF detection module
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// Import path graph for vulnerability tracking
import FullServerSideRequestForgeryFlow::PathGraph

// Identify vulnerable request flows
from
  // Origin point of user-controlled data
  FullServerSideRequestForgeryFlow::PathNode source,
  // Destination where data reaches HTTP request
  FullServerSideRequestForgeryFlow::PathNode sink,
  // HTTP client request being analyzed
  Http::Client::Request request
where
  // Verify data flows from source to sink
  FullServerSideRequestForgeryFlow::flowPath(source, sink) and
  // Connect request to sink's HTTP operation
  request = sink.getNode().(Sink).getRequest() and
  // Confirm complete URL control by user input
  fullyControlledRequest(request)
select
  // Report vulnerable request with flow details
  request, source, sink,
  // Describe vulnerability nature
  "Complete URL controlled by $@.", source.getNode(),
  "untrusted user input"