import python

/**
 * This query detects CWE-400: Uncontrolled Resource Consumption.
 * It looks for cases where a resource is not properly controlled.
 */

from FunctionCall fc, Variable v
where fc.getCallee().getName() = "open" and
      fc.getArgument(0) = v and
      not exists(VariableAssignment va | va.getLHS() = v and va.getRHS() instanceof LimitingExpression)
select fc, "This function call opens a resource without proper control."