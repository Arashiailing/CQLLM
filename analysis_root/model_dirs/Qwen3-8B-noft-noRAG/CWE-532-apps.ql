import python

from Call call, Argument arg
where call.getMethodName() in ("debug", "info", "warn", "error", "critical")
  and call.getCallee().getName() = "Logger"
  and arg.getKind() = "String"
select call, "Potential logging of sensitive information"