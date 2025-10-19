import python
import semmle.python.security.dataflow.StackTraceExposureQuery
import StackTraceExposureFlow::PathGraph

from StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink
where StackTraceExposureFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Stack trace exposure detected."