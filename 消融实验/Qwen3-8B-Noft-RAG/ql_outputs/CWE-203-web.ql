/**
 * @name CWE-203: Observable Discrepancy
 * @id py/web
 */
import python
import semmle.python.security.dataflow.StackTraceExposureQuery
import StackTraceExposureFlow::PathGraph

from StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink
where StackTraceExposureFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Information leakage due to observable discrepancy", source.getNode()