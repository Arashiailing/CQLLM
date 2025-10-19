import python

/**
 * CWE-20: Command Injection
 *
 * This query detects potential command injection vulnerabilities in Python code.
 * It looks for cases where user input is directly passed to a shell command.
 */

from Call call, Expr arg
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.check_call" or
      call.getCallee().getName() = "subprocess.check_output" or
      call.getCallee().getName() = "subprocess.Popen" and
      arg = call.getArgument(0)
select arg, "This argument is directly passed to a shell command, which may lead to command injection."