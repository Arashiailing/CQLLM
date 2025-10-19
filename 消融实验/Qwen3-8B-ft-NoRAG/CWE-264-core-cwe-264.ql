import python
import semmle.code.cpp.dataflow.DataFlow

from FunctionCall call, StringLiteral cmdStr, Variable userVar
where 
  call.getFunction().getName() = "os.system" or 
  call.getFunction().getName() = "subprocess.run" or 
  call.getFunction().getName() = "subprocess.call" or 
  call.getFunction().getName() = "subprocess.Popen"
  and 
  call.getArgument(0).getType().isString() 
  and 
  exists(Variable v | v.getName() = "user_input" and v.getDefinition().getExpression() = cmdStr)
select call, "Potential Command Injection vulnerability: User input is directly used in system command without proper sanitization."