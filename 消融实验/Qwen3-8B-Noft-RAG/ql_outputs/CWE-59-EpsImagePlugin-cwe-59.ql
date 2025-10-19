import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
  and sink.getNode().getKind() = "Call"
  and sink.getNode().getName() in ["open", "readfile", "os.system", "subprocess.check_output"]
select sink.getNode(), source, sink, "Potential CWE-59: Improper link resolution in path construction using untrusted data from $@", source.getNode(), "user-provided value"