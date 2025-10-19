/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/views-cwe-200
 */
import python
import semmle.python.security.dataflow.StackTraceExposureQuery
import StackTraceExposureFlow::PathGraph

from StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink
where StackTraceExposureFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Sensitive information exposed to unauthorized actor"