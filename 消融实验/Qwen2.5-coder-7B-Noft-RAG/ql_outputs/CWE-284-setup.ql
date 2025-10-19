/**
* @name CWE-284: Improper Access Control
*
@id py/setup
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Improper access control detected."