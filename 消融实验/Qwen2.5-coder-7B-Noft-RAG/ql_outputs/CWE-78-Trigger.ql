/**
* @name Uncontrolled comm
    and line
*
@description Using externally controlled strings in a comm
    and line may allow a malicious user to change the meaning of the command.
*
@id py/Trigger
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"