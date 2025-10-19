/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @id py/views-cwe-522
 */

import python
import semmle.python.security.dataflow.CredentialInjectionQuery

from CredentialInjectionFlow::PathNode source, CredentialInjectionFlow::PathNode sink
where CredentialInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Credential is stored in cleartext."