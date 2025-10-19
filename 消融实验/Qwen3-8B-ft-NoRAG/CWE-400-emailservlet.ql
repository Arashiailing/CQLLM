import python

/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @id py/emailservlet
 */

from MethodCall mc, Argument arg, CallExpr ce
where mc.getName() = "set_header" and
      mc.getArgument(0).getType().getName() = "str" and
      mc.getArgument(1).getType().getName() = "str" and
      ce = mc.getCallExpr() and
      ce.getArgument(1).getValue().toString() = "user_input"
select mc, "Potential HTTP Header Injection due to uncontrolled resource consumption"