import python
import semmle.code.cpp.dataflow.DataFlow

/** @predicate Finds calls to deserialization functions with user-controlled data */
from Call call, Argument arg, DataFlow::DataFlowNode source
where 
  (call.getCallee().getName() = "loads" and call.getModule().getName() = "pickle") or
  (call.getCallee().getName() = "load" and call.getModule().getName() = "pickle") or
  (call.getCallee().getName() = "load" and call.getModule().getName() = "yaml") or
  (call.getCallee().getName() = "safe_load" and call.getModule().getName() = "yaml") or
  (call.getCallee().getName() = "loads" and call.getModule().getName() = "json")
  and arg.getIndex() = 0
  and exists(DataFlow::isSource(source, arg))
select call, "Potential unsafe deserialization of user-controlled data"