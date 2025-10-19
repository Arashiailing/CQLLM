import python

/**
 * CWE-362: Command Injection
 */
from Call call, Argument arg
where call.getCallee().getName() = "subprocess.Popen"
  and arg = call.getArgument(0)
select arg, "This argument to subprocess.Popen may be vulnerable to command injection."