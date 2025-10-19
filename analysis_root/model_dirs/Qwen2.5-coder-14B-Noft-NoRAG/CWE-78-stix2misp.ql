import python

/**
 * This query detects potential command injection vulnerabilities in Python code.
 * It looks for cases where user-controlled input is directly used in a command execution function.
 */

from Call call, StringLiteral command, Expr userInput
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.check_call" or
      call.getCallee().getName() = "subprocess.Popen" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen"
  and call.getArgument(0) = command
  and exists(Expr arg | arg = userInput and call.getArgument(0).getAnArgument(arg))
select call, "Potentially vulnerable command execution detected. User input is directly used in the command."