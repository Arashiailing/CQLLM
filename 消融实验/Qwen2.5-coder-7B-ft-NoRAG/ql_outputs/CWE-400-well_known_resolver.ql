/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @id py/well_known_resolver
 */
import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
import ServerSideRequestForgeryFlow::PathGraph

from ServerSideRequestForgeryFlow::PathNode source, ServerSideRequestForgeryFlow::PathNode sink, Http::Client::Request request
where
  request = sink.getNode().(Sink).getRequest() and
  ServerSideRequestForgeryFlow::flowPath(source, sink) and
  not fullyControlledRequest(request)
select request, source, sink, "Resource consumption depends on a $@.", source.getNode(), "user-provided value"