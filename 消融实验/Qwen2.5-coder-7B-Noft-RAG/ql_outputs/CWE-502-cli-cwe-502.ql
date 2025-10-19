/**
* @name Deserialization of user-controlled data
*
@description Deserializing user-controlled data may allow attackers to execute arbitrary code.
*
@id py/cli-cwe-502
*/
import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
    where UnsafeDeserializationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Unsafe deserialization depends on a $@.", source.getNode(), "user-provided value"