import python
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
import UnsafeShellCommandConstructionFlow::PathGraph

from UnsafeShellCommandConstructionFlow::PathNode source, UnsafeShellCommandConstructionFlow::PathNode sink
where UnsafeShellCommandConstructionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This shell command depends on a $@", source.getNode(), "user-provided value"