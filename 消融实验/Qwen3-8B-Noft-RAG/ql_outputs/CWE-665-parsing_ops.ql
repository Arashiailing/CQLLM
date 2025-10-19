/**
 * @name CWE-665: Improper Initialization
 * @id py/parsing_ops
 */
import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper initialization detected through unsafe deserialization dependency on $@", source.getNode(), "user-provided value"