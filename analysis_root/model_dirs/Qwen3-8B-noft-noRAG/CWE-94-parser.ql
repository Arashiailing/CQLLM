import python

from Call call
where (call.getTarget().getName() = "eval" or call.getTarget().getName() = "exec")
  and call.getArgument(0).getType() = StringType
select call, "Potential code injection via eval or exec with string argument"