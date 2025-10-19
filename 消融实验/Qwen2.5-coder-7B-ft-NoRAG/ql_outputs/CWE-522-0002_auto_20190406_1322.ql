/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @id py/insufficiently-protected-credentials
 */

import python
import semmle.python.security.dataflow.CleartextCredentialsQuery
import CleartextCredentialsFlow::PathGraph

from CleartextCredentialsFlow::PathNode source, CleartextCredentialsFlow::PathNode sink
where CleartextCredentialsFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Credentials are stored in cleartext.", source.getNode(), "user-supplied value"