import python

/**
 * CWE-94: Command Injection
 * This query detects instances where user input is directly used in a system command.
 */

from Call call, StringLiteral command
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.run" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen"
  and call.getArgument(0) = command
select call, "This call to " + call.getCallee().getName() + " may be vulnerable to command injection."