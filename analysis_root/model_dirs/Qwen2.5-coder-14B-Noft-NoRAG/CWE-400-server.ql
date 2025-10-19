import python

/**
 * This query detects potential CWE-400: Uncontrolled Resource Consumption vulnerabilities.
 * It looks for cases where resources are allocated without proper limits or checks.
 */

from FunctionCall call, Expr resource
where call.getCallee().getName() = "open" and
      call.getArgument(0) = resource and
      not exists(Expr limit | call.getArgument(1) = limit)
select call, "This function call may lead to uncontrolled resource consumption."