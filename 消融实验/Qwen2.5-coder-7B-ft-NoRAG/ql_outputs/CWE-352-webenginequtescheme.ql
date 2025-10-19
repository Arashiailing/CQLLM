import python
import semmle.python.security.dataflow.UrlRedirectQuery

from UrlRedirectFlow::PathNode source, UrlRedirectFlow::PathNode sink
where UrlRedirectFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Untrusted URL redirection depends on a $@.", source.getNode(), "user-provided value"