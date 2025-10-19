import python

/**
 * CWE-400: Uncontrolled Resource Consumption
 * Detects cases where a resource is consumed without proper control.
 */

from FunctionCall call, Argument arg
where call.getCallee().getName() = "open"
  and arg = call.getArgument(0)
select arg, "Uncontrolled resource consumption detected in the open function call."