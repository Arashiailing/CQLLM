import python
import semmle.code.cpp.dataflow.DataFlow

from CallExpr call, Argument arg, StringLiteral cmdStr, Variable var
where 
  call.getCallee().getName() = "subprocess.run" or 
  call.getCallee().getName() = "os.system" or 
  call.getCallee().getName() = "subprocess.check_output"
  and arg.getArgIndex() = 0
  and arg.getType().isString()
  and cmdStr.getStringValue().contains("$((") or 
  cmdStr.getStringValue().contains("`") or 
  cmdStr.getStringValue().contains("|") or 
  cmdStr.getStringValue().contains(";") or 
  cmdStr.getStringValue().contains("&") or 
  cmdStr.getStringValue().contains("<") or 
  cmdStr.getStringValue().contains(">") or 
  cmdStr.getStringValue().contains("(") or 
  cmdStr.getStringValue().contains(")") or 
  cmdStr.getStringValue().contains("{") or 
  cmdStr.getStringValue().contains("}")
select call, "Potential command injection vulnerability detected in command execution."