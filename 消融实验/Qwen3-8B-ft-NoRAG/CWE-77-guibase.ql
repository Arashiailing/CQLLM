import python

from Call call
where call.getFunction().getName() in ["system", "call", "check_call", "Popen"] and
      (call.getFunction().getName() = "system" or
       (call.getFunction().getName() = "call" and call.getArguments().get(0).getValue().toString() contains "shell=True"))
select call, "Potential command injection via command execution"