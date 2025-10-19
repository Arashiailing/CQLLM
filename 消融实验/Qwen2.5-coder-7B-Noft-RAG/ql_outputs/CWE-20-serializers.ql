/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does not validate
    or incorrectly validates that the input has the properties that are required to process the data safely
    and correctly.
*
@id py/serializers
*/
import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
    where UnsafeDeserializationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Unsafe deserialization depends on a $@.", source.getNode(), "user-provided value"