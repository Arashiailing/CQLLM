/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @id py/zone
 */
import python
import semmle.python.security.dataflow.PathInjectionQuery
import semmle.python.security.dataflow.PathInjectionFlow

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
  and sink.getNode().getKind() = "Call"
  and sink.getNode().getName() in ["open", "os.path.join", "pathlib.Path"]
select sink.getNode(), source, sink, "Potential CWE-59: Improper link resolution before file access", source.getNode(), "untrusted data"