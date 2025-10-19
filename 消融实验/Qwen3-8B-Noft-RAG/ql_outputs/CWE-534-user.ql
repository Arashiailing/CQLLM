import python
import semmle.python.security.dataflow.LogInjectionQuery
import LogInjectionFlow::PathGraph

from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink)
  and sink.getNode().getKind() = "Call"
  and sink.getNode().getSymbolName() in ("debug", "info", "warning", "error", "critical")
select sink.getNode(), source, sink, "Sensitive data stored in log file: $@", source.getNode(), "user-provided value"