import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
import PartialServerSideRequestForgeryFlow::PathGraph

from PartialServerSideRequestForgeryFlow::PathNode source, PartialServerSideRequestForgeryFlow::PathNode sink, Http::Client::Request request
where
  request = sink.getNode().(Sink).getRequest()
  and PartialServerSideRequestForgeryFlow::flowPath(source, sink)
  and not fullyControlledRequest(request)
select
  request,
  source,
  sink,
  "Part of the URL of this request depends on a $@.",
  source.getNode(),
  "user-provided value"