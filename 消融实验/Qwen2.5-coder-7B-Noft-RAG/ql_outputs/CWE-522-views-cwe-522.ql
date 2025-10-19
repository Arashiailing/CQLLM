/**
* @name CWE-522: Insufficiently Protected Credentials
*
@id py/views-cwe-522
*/
import python
import semmle.python.security.dataflow.CleartextCredentialsQuery
from CleartextCredentialsFlow::PathNode source, CleartextCredentialsFlow::PathNode sink
    where CleartextCredentialsFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Credentials are stored in cleartext at $@.", source.getNode(), "user-supplied input"