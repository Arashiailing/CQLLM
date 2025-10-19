/**
 * @name CWE-284: Improper Access Control
 * @id py/sandbox
 */
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper access control due to a $@.", source.getNode(), "user-provided value"