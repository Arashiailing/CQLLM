import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.nodes.BaseNode

from Call call, Argument arg
where call = getCallTo("read")
  and arg = call.getArgument(0)
  and arg.getType().getName() = "size_t"
  and arg.getValue().toInt() > 1024
select call, "Potential out-of-bounds read detected with size larger than 1024"