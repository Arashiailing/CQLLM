import python
import semmle.code.java.dataflow.DataFlow

from Call call, Argument arg
where 
  call.getSymbol().getName() = "redirect" and 
  arg.getPosition().getFile().getName() = "app.py" and 
  arg.getValue().getType().toString() = "str" and 
  isUserInput(arg.getValue())
select call.getLocation(), "Potential URL redirection based on unvalidated user input"