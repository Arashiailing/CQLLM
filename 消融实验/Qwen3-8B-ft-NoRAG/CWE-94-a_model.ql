import python

from Call call
where
  (call.getCallee() = "subprocess.run" or
   call.getCallee() = "subprocess.call" or
   call.getCallee() = "os.system") and
  (call.getArgument("shell") = true or
   call.getArgument("shell") = "True" or
   call.getArgument("shell") = "true") and
  (call.getArgument("args") is String or
   call.getArgument("cmd") is String or
   call.getArgument("command") is String)
select call, "Potential command injection"