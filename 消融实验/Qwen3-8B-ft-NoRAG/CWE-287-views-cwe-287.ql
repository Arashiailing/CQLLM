import py

from Call c
where c.getFunction().getName() = "==" 
  and c.getArgument(0).getType() = "str"
  and c.getArgument(1).getType() = "str"
  and (c.getArgument(1).getValue().getLiteral() = "admin" or c.getArgument(1).getValue().getLiteral() = "user")
  and exists(Call input_call where input_call.getFunction().getName() = "input" and input_call.getArgument(0).getVariable() = c.getArgument(0).getVariable())
select c, "Potential CWE-287: Improper Authentication - Direct string comparison of user input to hardcoded identity."