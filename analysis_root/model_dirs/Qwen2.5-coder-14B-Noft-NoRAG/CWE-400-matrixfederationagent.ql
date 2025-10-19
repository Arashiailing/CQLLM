import python

/**
 * CWE-400: Uncontrolled Resource Consumption
 * Detects instances where resource allocation is not properly controlled.
 */

from FunctionCall fc, Variable v
where fc.getCallee().getName() = "open"
  and fc.getArgument(0) = v
select v, "Uncontrolled resource consumption detected. The variable '"
  + v.getName() + "' is used to open a resource without proper control."