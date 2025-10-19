/**
* @name CWE-522: Insufficiently Protected Credentials
*
@id py/insufficiently-protected-credentials
*
@tags security
* @kind problem
* @problem.severity warning
* @security-severity 6.5
* @precision high
*/
import python
import semmle.python.security.dataflow.CredentialsQuery
import CredentialsFlow::PathGraph
from CredentialsFlow::PathNode source, CredentialsFlow::PathNode sink
    where CredentialsFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Credentials are stored in a $@ without proper protection.", source.getNode(), "plaintext"