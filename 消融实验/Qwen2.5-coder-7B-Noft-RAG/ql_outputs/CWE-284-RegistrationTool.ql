/**
* @name CWE-284: Improper Access Control
*
@id py/registration-tool
*/
import python
import semmle.python.security.dataflow.RegistrationToolQuery
from RegistrationToolFlow::PathNode source, RegistrationToolFlow::PathNode sink
    where RegistrationToolFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Improper access control detected at $@.", source.getNode(), "user-supplied input"