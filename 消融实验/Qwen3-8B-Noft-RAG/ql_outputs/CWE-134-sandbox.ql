/**
 * @name CWE-134: Use of Externally-Controlled Format String
 * @id py/sandbox
 */
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This format string depends on a $@.", source.getNode(), "externally controlled value"