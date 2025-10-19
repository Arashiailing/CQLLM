import python
import semmle.code.cpp.dataflow.DataFlow

from CallExpr call, Argument arg, UserInput userInput
where 
  call.getCallee().getName() = "subprocess.check_output" or 
  call.getCallee().getName() = "subprocess.run" or 
  call.getCallee().getName() = "os.system" or 
  call.getCallee().getName() = "subprocess.call"
  and arg.getArgPosition() = 0
  and arg.getType().isString()
  and exists (userInput, arg.getValue() = userInput.getOrigin())
select call.getLocation(), "Potential command injection vulnerability due to unvalidated user input in command execution function."