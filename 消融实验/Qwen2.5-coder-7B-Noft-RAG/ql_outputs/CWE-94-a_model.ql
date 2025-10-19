/**
* @name Code injection
*
@id py/a_model
*/
import python
import semmle.python.security.dataflow.CodeInjectionQuery
import CodeInjectionFlow::PathGraph
from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
    where CodeInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(), "user-provided value"