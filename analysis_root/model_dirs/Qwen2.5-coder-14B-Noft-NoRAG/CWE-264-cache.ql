import python

/**
 * Query to detect CWE-264: Stack Trace Exposure
 * This query looks for instances where stack traces are exposed in error messages.
 */

from Call call, ExceptionHandlingClause eh
where call.getCallee().getName() = "print" and
      call.getArgument(0) instanceof StringLiteral and
      call.getArgument(0).getValue().contains("Traceback") and
      eh.getCatchClause() = call.getEnclosingCatchClause()
select eh, "This catch clause may expose stack traces in error messages, which could lead to CWE-264: Stack Trace Exposure."