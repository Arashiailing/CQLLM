import python
import semmle.code.scalacode.scalacode
import semmle.code.cpp.dataflow.DataFlow
import semmle.python.security.PythonSecurity

from CallExpr call, Argument arg, StringLiteral strLit
where 
  (call.getFunction().getName() = "os.system" or 
   call.getFunction().getName() = "subprocess.call" or 
   call.getFunction().getName() = "subprocess.check_call" or 
   call.getFunction().getName() = "subprocess.Popen" or 
   call.getFunction().getName() = "subprocess.run") and
  arg.getArgumentPosition() = 0 and
  arg.getValue() = strLit and
  strLit.getStringValue().matches(".*\$\{.*\}.*") or 
  strLit.getStringValue().matches(".*`.*`.*") or
  strLit.getStringValue().matches(".*;.*") or
  strLit.getStringValue().matches(".*|.*")
select call, "Potential command injection vulnerability due to unsanitized user input in command execution."