import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

from HeaderInjectionFlow::PathNode source, HeaderInjectionFlow::PathNode sink
where HeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This HTTP header is constructed from a $@.", source.getNode(), "user-provided value"