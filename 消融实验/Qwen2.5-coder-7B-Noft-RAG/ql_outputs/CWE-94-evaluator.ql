/**
* @name Code injection
*
@description Interpreting unsanitized user input as code allows a malicious user to perform arbitrary * code execution.
*
@id py/evaluator
*/
import python
import semmle.python.security.dataflow.EvalQuery
from EvalFlow::PathNode source, EvalFlow::PathNode sink
    where EvalFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(), "user-provided value"