/**
* @name CWE-254: Default Credentials
* @kind problem
* @problem.severity error
* @security-severity 9.0
* @precision high
*
@id py/default-credentials
*
@tags security * external/cwe/cwe-254
*/
import python
import semmle.python.security.dataflow.DefaultCredentialsQuery
import DefaultCredentialsFlow::PathGraph
from DefaultCredentialsFlow::PathNode source, DefaultCredentialsFlow::PathNode sink
    where DefaultCredentialsFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Default credentials are being used."