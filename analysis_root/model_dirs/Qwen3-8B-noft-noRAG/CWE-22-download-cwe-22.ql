import python
import dataflow

/** @name Uncontrolled data used in path expression */
from Call call, DataFlow::Node source, DataFlow::Node sink
where call.getTarget().getModule() = "os" and call.getTarget().getName() = "path" and call.getTarget().getMethod() = "join"
and exists (source, sink)
and source.getKind() = DataFlow::SourceKind.USER_INPUT
and sink.getKind() = DataFlow::SinkKind.FILE_ACCESS
select call.getLocation(), "Uncontrolled data used in path expression."