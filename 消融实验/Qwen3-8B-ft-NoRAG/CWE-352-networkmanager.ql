import python

from Call call
where call.getCallee().getName() = "redirect"
  and call.getArguments().size() > 0
  and call.getArgument(0).getExpression().isUserInput()
select call, "Potential URL redirect vulnerability due to unvalidated input"