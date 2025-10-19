import py

from Call call, Argument arg
where 
  call.getCallee().getName() = "redirect" and 
  arg.getArgumentIndex() = 0 and 
  arg.getExpression().isInputSource()
select call, "Potential URL redirection based on unvalidated user input"