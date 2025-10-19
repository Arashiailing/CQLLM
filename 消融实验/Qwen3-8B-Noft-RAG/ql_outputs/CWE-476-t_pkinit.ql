import python
import semmle.python.security.dataflow.StackTraceExposureQuery
import StackTraceExposureFlow::PathGraph

from LogInjectionFlow::PathNode source, StackTraceExposureFlow::PathNode sink
where StackTraceExposureFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential stack trace exposure via $@", source.getNode()