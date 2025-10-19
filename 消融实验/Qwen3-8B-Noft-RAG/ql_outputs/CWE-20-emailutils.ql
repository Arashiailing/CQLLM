import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery
import HttpHeaderInjectionFlow::PathGraph

from HttpHeaderInjectionFlow::PathNode source, HttpHeaderInjectionFlow::PathNode sink
where HttpHeaderInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "HTTP header constructed from unvalidated input", source.getNode()