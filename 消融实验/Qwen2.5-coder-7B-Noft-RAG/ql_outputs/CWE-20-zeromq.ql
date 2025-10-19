/**
* @name CWE-20: Improper Input Validation
*
@id py/zeromq
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Comm
    and injection vulnerability detected."