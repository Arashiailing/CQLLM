/**
 * @name CWE CATEGORY: Permissions, Privileges, and Access Controls
 * @id py/bccache
 */
import python
import semmle.python.security.dataflow.UnsafeDeserializationQuery
import semmle.python.security.dataflow.UnsafeDeserializationFlow

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential unsafe deserialization leading to permission issues", source.getNode()