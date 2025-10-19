import python

from Call call
where 
  (call.getCallee() = "subprocess.run" or 
   call.getCallee() = "subprocess.call" or 
   call.getCallee() = "subprocess.check_output" or 
   call.getCallee() = "os.system")
  and (
    (call.getCallee() = "subprocess.run" and call.getArgument("shell").getValue() = true) or
    (call.getCallee() = "subprocess.call" and call.getArgument("shell").getValue() = true) or
    (call.getCallee() = "subprocess.check_output" and call.getArgument("shell").getValue() = true) or
    (call.getCallee() = "os.system" and call.getArgument(0).getType().isString()))
  and not call.getArgument(0).isStringLiteral()
select call, "Unsanitized command arguments passed to subprocess or os.system with shell=True or string-based API, potentially allowing command injection."