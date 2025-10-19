/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @id py/manage
 */
import python
import semmle.python.security.dataflow.CredentialsManagement

from CredentialsManagement::PathNode source, CredentialsManagement::PathNode sink
where CredentialsManagement::flowPath(source, sink)
select sink.getNode(), source, sink, "Credentials stored in cleartext", source.getNode(), "sensitive data"