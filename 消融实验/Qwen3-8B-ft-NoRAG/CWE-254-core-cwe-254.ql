import py

from Call call
where call.getCallee().getName() = "eval" or call.getCallee().getName() = "exec" or
      (call.getCallee().getName() = "call" and call.getArgument(0).getName() = "shell")
select call, "Potential code injection via dynamic code execution or command injection"