import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import HeaderInjectionFlow::PathGraph

from HeaderInjectionFlow::PathNode source, HeaderInjectionFlow::PathNode sink
where HeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Resource consumption due to uncontrolled HTTP header injection.", source.getNode(), "user-provided value"