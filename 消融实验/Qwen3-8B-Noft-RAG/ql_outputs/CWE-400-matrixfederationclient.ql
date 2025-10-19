/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @id py/matrixfederationclient
 */
import python
import semmle.python.security.dataflow.LogInjectionQuery
import LogInjectionFlow::PathGraph

from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Resource consumption vulnerability due to a $@.", source.getNode(), "uncontrolled data"