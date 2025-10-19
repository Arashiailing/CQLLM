import python
import semmle.python.security.dataflow.PathInjectionQuery

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential out-of-bounds read at $@.", source.getNode(), "user-provided value"