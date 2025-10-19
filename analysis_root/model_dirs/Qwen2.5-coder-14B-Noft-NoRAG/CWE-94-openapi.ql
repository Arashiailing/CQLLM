import python

/**
 * This query detects potential CWE-94: Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection').
 */
from Call call, StringLiteral command
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.check_call" or
      call.getCallee().getName() = "subprocess.check_output" or
      call.getCallee().getName() = "subprocess.Popen" and
      call.getArgument(0) = command
select command, "This string literal is used in an OS command call and may be vulnerable to OS command injection."