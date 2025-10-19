import python

/**
 * CWE-264: Command Injection
 * Detects the use of subprocess calls with user input.
 */
from Call call, StringLiteral cmd
where call.getCallee().getName() = "subprocess.call" and
      call.getArgument(0) = cmd and
      exists(StringLiteral input | input.getAString() = "%s" and call.getArgument(1) = input)
select call, "Potentially vulnerable to command injection: " + cmd.getValue()