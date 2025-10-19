import python
import external.VCS

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Untrusted data used in path expression", source.getNode(), "user-provided value"