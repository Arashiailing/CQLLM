import python
import semmle.python.dataflow.new.DataFlow

from Call call, DataFlow::Node source, DataFlow::Node sink
where call.getTarget().getName() = "copy" and
      DataFlow::hasFlowFrom(source, sink) and
      source.isInput()
select call, "Buffer copy without size check detected."