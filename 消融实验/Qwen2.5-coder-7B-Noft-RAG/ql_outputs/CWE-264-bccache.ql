/**
* @name CWE-264: Unsafe Deserialization
* @category Permissions, Privileges,
    and Access Controls
*
@description Deserializing untrusted data may lead to security vulnerabilities.
*
@id py/bccache
*/
import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
    where UnsafeDeserializationFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Potential unsafe deserialization at $@.", source.getNode(), "untrusted data"