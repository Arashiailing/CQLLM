import python
import semmle.python.security.dataflow.PathInjectionQuery
import semmle.python.security.dataflow.PathInjectionFlow

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Untrusted data used in path expression", source.getNode(), "user-supplied input"