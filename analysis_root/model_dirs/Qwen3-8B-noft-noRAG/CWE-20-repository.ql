import python

from Call call, Argument arg
where
  call.getCallee().getName() in ["run", "call", "check_output", "Popen"] and
  call.getModule() = "subprocess" and
  (arg.getValue().getType().isString() or arg.getValue().getType().isArray())
select call.getLocation(), "Potential command injection due to unvalidated input in subprocess call."