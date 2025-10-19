import python

/**
 * CWE-20: Improper Input Validation
 *
 * This query detects instances where the stack trace is exposed
 * in the application's output, which can leak sensitive information.
 */

from Call call, Function function
where function.getName() = "print" or function.getName() = "write"
  and call.getCallee() = function
  and exists(Call traceCall | traceCall.getCallee().getName() = "traceback.format_exc" or traceCall.getCallee().getName() = "traceback.format_stack")
  and traceCall.getCaller() = call
select call, "This call to print or write may expose the stack trace, leading to sensitive information leakage."