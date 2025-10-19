import python
import semmle.python.security.dataflow.SSLCAQuery
import SSLCAFlow::PathGraph

from SSLCAFlow::PathNode source, SSLCAFlow::PathNode sink
where SSLCAFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "SSL certificate validation is bypassed through $@.", source.getNode(), "user-supplied input"