/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @id py/views-cwe-522
 */
import python
import semmle.python.security.dataflow.CredentialsStorageQuery
import semmle.python.dataflow.new.DataFlow

from CredentialsStorageFlow::PathNode source, CredentialsStorageFlow::PathNode sink
where CredentialsStorageFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Credentials stored in cleartext", source.getNode()