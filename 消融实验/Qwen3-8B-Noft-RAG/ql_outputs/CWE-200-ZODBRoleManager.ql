/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/ZODBRoleManager
 */
import python
import semmle.python.security.dataflow.SensitiveDataStorageQuery
import semmle.python.dataflow.new.DataFlow

from SensitiveDataStorageFlow::PathNode source, SensitiveDataStorageFlow::PathNode sink
where SensitiveDataStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information stored in cleartext", source.getNode(), "unencrypted data"