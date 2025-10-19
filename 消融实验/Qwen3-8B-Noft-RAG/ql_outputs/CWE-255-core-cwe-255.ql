/**
 * @name CWE-255: Cleartext Storage
 * @id py/core-cwe-255
 */
import python
import semmle.python.security.dataflow.SecretDetectionQuery
import semmle.python.security.dataflow.SecretStorageFlow::PathGraph

from SecretStorageFlow::PathNode source, SecretStorageFlow::PathNode sink
where SecretStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive data stored in cleartext", source.getNode(), "unencrypted secret"