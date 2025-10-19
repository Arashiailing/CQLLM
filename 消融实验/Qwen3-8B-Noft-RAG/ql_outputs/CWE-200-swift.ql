/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/swift
 */
import python
import semmle.python.security.dataflow.LogInjectionQuery
import LogInjectionFlow::PathGraph

from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information exposed in logs", source.getNode(), "user-provided value"