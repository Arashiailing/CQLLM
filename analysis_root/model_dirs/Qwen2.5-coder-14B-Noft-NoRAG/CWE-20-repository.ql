import python

/**
 * CWE-20: Command Injection
 *
 * This query detects potential command injection vulnerabilities
 * in Python code. It looks for cases where user input is directly
 * passed to system commands without proper validation.
 */

from Call call, StringLiteral literal, Arg arg
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen"
  and arg = call.getArgument(0)
  and literal = arg.getAChild()
select call, "Potentially vulnerable to command injection: " + literal.getValue()