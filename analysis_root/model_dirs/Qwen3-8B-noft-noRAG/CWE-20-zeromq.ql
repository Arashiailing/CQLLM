import python
import semmle.code.cpp.dataflow.DataFlow

from Call call, Parameter p, StringLiteral strLit
where
  call.getTarget().getName() = "subprocess.Popen" or
  call.getTarget().getName() = "subprocess.call" or
  call.getTarget().getName() = "os.system"
  and
  p.isPositionalParameter()
  and
  (p.getValue() = strLit or p.getValue().toString().contains("+")) // Check for string concatenation
  and
  exists(Argument arg | arg.getArgIndex() = 0 and arg.getType().isSubtypeOf(python.StdlibTypes.StringType))
select call.getLocation(), "Potential command injection due to unvalidated user input in command execution."