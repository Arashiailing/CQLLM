/**
* @name CWE-269: Improper Privilege Management
*
@description The product does not properly assign, modify, track,
    or check privileges f
    or an actor, creating an unintended sphere of control f
    or that actor.
*
@id py/autojump
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"