import python

/**
 * This query detects potential CWE-264: Command Injection vulnerabilities in Python code.
 * CWE-264 occurs when an application constructs a command string from external input and
 * executes it using a system call, without proper validation or sanitization.
 */

from Call call, StringLiteral command
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.check_call" or
      call.getCallee().getName() = "subprocess.check_output" or
      call.getCallee().getName() = "subprocess.Popen" and
      call.getArgument(0) = command
select call, "This call to subprocess function may be vulnerable to command injection because it uses a string literal directly."