/**
* @name CWE-522: Insufficiently Protected Credentials
*
@description Storing credentials in plain text is insecure.
* @kind path-problem
* @problem.severity error
* @security-severity 8.8
* @precision high
*
@id py/base-cwe-522
*
@tags security * external/cwe/cwe-522
*/
import python
import semmle.python.security.dataflow.CredentialsQuery
import CredentialsFlow::PathGraph
from CredentialsFlow::PathNode source, CredentialsFlow::PathNode sink
    where CredentialsFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Credentials are stored in plain text."