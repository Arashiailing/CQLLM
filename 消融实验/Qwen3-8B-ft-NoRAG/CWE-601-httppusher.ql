import python

from Call call, Argument arg
where call.getSelector().getName() = "redirect"
  and arg = call.getArgument(0)
  and arg.getType().isString()
  and arg.getSource().isUserInput()
select call, "Potential URL redirection based on unvalidated user input"