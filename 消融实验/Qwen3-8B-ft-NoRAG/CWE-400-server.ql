import python

from Call call, Argument arg
where call.getMethod().getName() = "split" and arg.getArgumentIndex() = 0
  and arg.getExpression().isUserInput()
select call, "Potential CWE-400: Uncontrolled Resource Consumption via unbounded split operation"