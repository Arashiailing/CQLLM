import python
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

from HttpHeaderInjectionQuery::PathNode source, HttpHeaderInjectionQuery::PathNode sink
where HttpHeaderInjectionQuery::flowPath(source, sink)
select sink.getNode(), source, sink, "HTTP request/response smuggling vulnerability due to inconsistent interpretation of headers.", source.getNode(), "user-controlled header value"