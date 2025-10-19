import python

/**
 * This query detects unsafe shell command construction in Python code.
 * CWE-74: Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection')
 */

from Call call, StringLiteral cmd
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.check_call" or
      call.getCallee().getName() = "subprocess.check_output" or
      call.getCallee().getName() = "subprocess.Popen" and
      call.getArgument(0) = cmd
select call, "Unsafe shell command construction detected: " + cmd.getValue()