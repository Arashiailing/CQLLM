import python

from Call call
where call.getCallee().getName() in ["log", "debug", "info", "warning", "error", "critical"]
  and call.getArgument(0).getType().isString()
select call, "Potential cleartext logging of sensitive information"