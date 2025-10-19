import python

from CallExpr call, Argument arg
where call.getCallee().getName() = "join" and call.getModule() = "os.path"
  and arg is Argument of call
  and exists (CallExpr userCall where userCall.getModule() = "flask" and userCall.getCallee().getName() = "args" and userCall.getArgument(0).getValue() = arg.getValue())
select call, "Potential Path Injection via os.path.join with user input"