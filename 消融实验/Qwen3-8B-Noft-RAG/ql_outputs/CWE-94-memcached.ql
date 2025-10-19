import python
import semmle.python.security.dataflow.CodeInjectionQuery

from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
where CodeInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(), "user-provided value"