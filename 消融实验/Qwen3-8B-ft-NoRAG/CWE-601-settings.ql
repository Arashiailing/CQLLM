import python

from Call call, Argument arg
where call.getMethod().getName() = "redirect" and
      arg.getArgumentPosition() = 0 and
      arg.getExpression().isUserInput()
select call, "Potential URL redirection based on unvalidated user input."