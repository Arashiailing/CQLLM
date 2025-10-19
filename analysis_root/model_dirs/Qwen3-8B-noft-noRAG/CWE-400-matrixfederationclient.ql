import python

/** @name Log Injection */
from Call call, FunctionDecl log_func
where
  log_func.getName() in ("info", "debug", "warning", "error", "critical") and
  log_func.getModule().getName() = "logging" and
  call.getTarget() = log_func and
  exists (call.getArgument(), arg |
    arg.getType().isString() and
   !arg.isKeywordArgument()
  )
select call, "Potential Log Injection via unfiltered user input in logging call."