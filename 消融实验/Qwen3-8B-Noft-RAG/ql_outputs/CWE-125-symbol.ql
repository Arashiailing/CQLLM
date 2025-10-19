import python
import semmle.code.java.dataflow.DataFlow
import semmle.python.security.dataflow.PathInjectionQuery

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Out-of-bounds read detected via untrusted data", source.getNode()