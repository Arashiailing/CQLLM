import python

/**
 * @name CWE-255: Unsafe Shell Command Construction
 * @description Detects the use of subprocess calls with user input that could lead to command injection vulnerabilities.
 * @id py/engine
 */

from CallExpr call, StringLiteral command
where call.getCallee().getName() = "subprocess.Popen" and
      call.getArgument(0) = command and
      command.getValue().contains("%s") or command.getValue().contains("%d")
select call, "This call to subprocess.Popen may be vulnerable to command injection due to user input being included in the command string."