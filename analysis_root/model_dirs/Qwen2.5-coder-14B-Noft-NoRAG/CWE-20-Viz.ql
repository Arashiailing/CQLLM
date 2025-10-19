import python

/**
 * CWE-20: Command Injection
 * This query detects potential command injection vulnerabilities in Python code.
 * It looks for cases where user input is directly passed to a system command.
 */

from Call call, StringLiteral command, Expr userInput
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.check_call" or
      call.getCallee().getName() = "subprocess.Popen" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen"
  and call.getArgument(0) = command
  and exists(Expr arg | arg in call.getArguments() and userInput = arg)
select call, "Potential command injection vulnerability detected. User input is directly passed to a system command."