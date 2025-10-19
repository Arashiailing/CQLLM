import python

/**
 * CWE-74: Command Injection
 */
from Call call, StringLiteral command, Expr userInput
where call.getCallee().getName() = "subprocess.call" and
      call.getArgument(0) = command and
      command.getValue() instanceof userInput
select call, "This call to subprocess.call may be vulnerable to command injection because it uses user-controlled input."