/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/formats
 */
import python
import semmle.python.security.dataflow.LogInjectionQuery
import LogInjectionFlow::PathGraph

from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information logged without encryption", source.getNode()