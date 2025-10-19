import python

/**
 * CWE-19: Command Injection
 * Detects potential command injection vulnerabilities in Python code.
 */

from Call call, StringLiteral cmd
where call.getCallee().getName() = "subprocess.call" and
      call.getArgument(0) = cmd and
      cmd.getValue().contains("$") or cmd.getValue().contains("%")
select call, "Potential command injection vulnerability detected. The command string may be vulnerable to injection."