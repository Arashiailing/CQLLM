import python

from PyFunctionCall call, PyVariableAccess var, PyStringConcat concat
where call.getName() = "input" and call.getArgs().has(var)
  and concat.getStringPart().contains(var.getName())
select concat.getLocation(), "Uncontrolled data used in path expression"