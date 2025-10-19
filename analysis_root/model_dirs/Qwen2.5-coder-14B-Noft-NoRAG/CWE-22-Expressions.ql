import python

from FunctionCall call, Expr arg
where call.getCallee().getName() = "open" and
      call.getArgument(0) = arg and
      arg instanceof UserInput
select call, "Uncontrolled data used in path expression"