import python

from Call call, Argument arg
where call.getMethod().getName() in ["check_output", "run", "call", "Popen", "system"] and
      arg.getArgumentPosition() = 0 and
      arg.getValue().isUserInput()
select call, "Potential command injection via unsafe command execution."