import python

/**
 * CWE-203: StackTraceExposureQuery
 * This query detects the exposure of stack traces in Python web applications.
 */

from Call call, ExceptionHandlingStatement eh
where call.getCallee().getName() = "print" and
      eh.getException() = call.getArgument(0) and
      eh instanceof TryCatchStatement
select eh, "This code exposes stack traces by printing exceptions."