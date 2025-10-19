import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.ControlFlow

from Call call, Argument arg
where call.getTarget().getName() = "read"
  and arg.getIndex() < 0 or arg.getIndex() > 1024  // 假设检测固定大小缓冲区的越界访问
select call, "Potential out-of-bounds read detected"