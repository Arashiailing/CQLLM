import python
import semmle.python.security.dataflow.ServerSideTemplateInjectionQuery
import ServerSideTemplateInjectionFlow::PathGraph
from ServerSideTemplateInjectionFlow::PathNode source, ServerSideTemplateInjectionFlow::PathNode sink
    where ServerSideTemplateInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This server-side template injection depends on a $@.", source.getNode(), "user-provided value"