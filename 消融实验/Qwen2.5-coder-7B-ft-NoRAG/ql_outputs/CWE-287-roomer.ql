/**
 * @name CWE-287: Improper Authentication
 * @id py/roomer
 */
import python
import semmle.python.security.dataflow.CommandInjectionQuery

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper authentication detected."