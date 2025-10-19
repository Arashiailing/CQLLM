/**
 * @name CWE-134: Use of Externally-Controlled Format String
 * @id py/nodes
 */
import python
import semmle.python.security.dataflow.LogInjectionQuery
import LogInjectionFlow::PathGraph

from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Format string depends on a $@.", source.getNode(), "externally-controlled value"