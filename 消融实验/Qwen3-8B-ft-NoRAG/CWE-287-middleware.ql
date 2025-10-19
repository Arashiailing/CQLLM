import python

from Call call, Method method
where method.getName() = "process_request"
  and call.getTarget().getName() = "authenticate"
  and call.getArg(0).getType().isString()
  and call.getReturn().getType().isBoolean()
  and not exists (call.getReturn().getUsage() = "used")
select call, "Potential CWE-287: Improper Authentication detected in authentication check."