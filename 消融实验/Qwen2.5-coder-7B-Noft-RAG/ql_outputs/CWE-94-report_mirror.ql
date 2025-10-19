/**
* @name Code injection
*
@description Interpreting unsanitized user input as code allows a malicious user to perform arbitrary * code execution.
*
@id py/report_mirror
*/
import python
import semmle.python.security.dataflow.CodeInjectionQuery
import CodeInjectionFlow::PathGraph
from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
    where CodeInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(), "user-provided value"