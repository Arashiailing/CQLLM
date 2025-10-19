/**
 * @name CWE-918: Server-Side Request Forgery (SSRF)
 * @description Partial server-side request forgery.Making a network request to a URL that is partially user-controlled allows for request forgery attacks..
 *              The web server receives a URL or similar request from an upstream component and retrieves the contents of this URL, but it does not sufficiently ensure that the request is being sent to the expected destination.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/registerservlet
 * @tags security
 *       external/cwe/cwe-918
 */

import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
import PartialServerSideRequestForgeryFlow::PathGraph

from 
  PartialServerSideRequestForgeryFlow::PathNode source,
  PartialServerSideRequestForgeryFlow::PathNode sink,
  Http::Client::Request request

where 
  request = sink.getNode().(Sink).getRequest() and
  PartialServerSideRequestForgeryFlow::flowPath(source, sink) and
  not fullyControlledRequest(request)

select request, source, sink, "Part of the URL of this request depends on a $@.", source.getNode(), "user-provided value"