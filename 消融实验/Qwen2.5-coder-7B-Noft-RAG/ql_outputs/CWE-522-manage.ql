/**
* @name CWE-522: Insufficiently Protected Credentials
*
@description Storing credentials in plain text can expose them to unauthorized access.
* @kind path-problem
* @problem.severity warning
* @precision high
* @security-severity 9.1
*
@id py/manage
*/
import python
import semmle.python.security.dataflow.CredentialsQuery
from CredentialsFlow::PathNode source, CredentialsFlow::PathNode sink
    where CredentialsFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Credentials are stored in plain text.", source.getNode()