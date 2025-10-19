/**
 * @name Code injection
 * @description Interpreting unsanitized user input as code allows a malicious user to perform arbitrary code execution.
 * @id py/openapi
 */
import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(),  "user-provided value"