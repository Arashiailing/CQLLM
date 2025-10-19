import python

from Call call
where 
  (call.getFunction().getModule() = python.Module("subprocess") and 
   call.getFunction().getName() in ("run", "call", "check_call", "check_output")) or
  (call.getFunction().getModule() = python.Module("os") and 
   call.getFunction().getName() = "system")
and 
  (exists(Argument arg | 
    (arg.getName() = "shell" and arg.getValue().getValue() = true) or
    (arg.getName() = "args" or arg.getName() = "cmd") and
    arg.getValue().getType() = python.StringType())
  )
select call, "Potential command injection via unsafe command execution with unvalidated input."