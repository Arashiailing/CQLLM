import python

/**
 * This query detects potential Log Injection vulnerabilities (CWE-134) in Python code.
 * It looks for calls to logging functions where the format string is derived from user input.
 */

from FunctionCall call, StringLiteral fmt, Expr userInput
where call.getCallee().getName() = "log" and
      call.getArgument(0) = fmt and
      userInput instanceof ExternalInput and
      userInput = call.getArgument(1)
select call, "This call to log() uses a format string that is derived from user input, which could lead to log injection."