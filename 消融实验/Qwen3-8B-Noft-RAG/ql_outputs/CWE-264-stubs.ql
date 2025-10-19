import python
import semmle.python.security.dataflow.PermissionControlQuery
import PermissionControlFlow::PathGraph

from PermissionControlFlow::PathNode source, PermissionControlFlow::PathNode sink
where PermissionControlFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential permission elevation via $@.", source.getNode(), "user-controlled input"