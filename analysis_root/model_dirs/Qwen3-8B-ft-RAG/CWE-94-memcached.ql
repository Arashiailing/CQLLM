import python
import semmle.python.security.dataflow.CodeInjectionQuery
import semmle.python.security.dataflow.trees.CodeInjectionFlowGraph

from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
where CodeInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(), "user-provided value"