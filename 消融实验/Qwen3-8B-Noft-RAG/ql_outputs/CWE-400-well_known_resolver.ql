import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
import semmle.python.security.dataflow.PartialServerSideRequestForgeryFlow

from PartialServerSideRequestForgeryFlow::PathNode source, PartialServerSideRequestForgeryFlow::PathNode sink, Http::Client::Request request
where request = sink.getNode().(Sink).getRequest() and PartialServerSideRequestForgeryFlow::flowPath(source, sink) and not fullyControlledRequest(request)
select request, source, sink, "Uncontrolled resource consumption via SSRF detected", source.getNode(), "user-provided value"