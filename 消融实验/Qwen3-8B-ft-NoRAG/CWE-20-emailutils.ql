import python

from Call call, Parameter param, Variable var
where (call.getMethod().getName() = "add_header" or call.getMethod().getName() = "set_header")
  and call.getArgumentCount() >= 2
  and param = call.getArgument(1)
  and var = param.getValue()
  and isUserInput(var)
select call, "Potential HTTP header injection via HTTP header setting method with unvalidated user input."