import python
import semmle.code.cpp.dataflow.DataFlow

from FunctionCall call, Parameter p, Argument arg
where 
  call.getMethod().getName() = "join" and 
  (call.getDeclaringType().getFullyQualifiedName() = "os.path" or 
   call.getDeclaringType().getFullyQualifiedName() = "pathlib.PurePath") and
  arg.getValue().getValue().toString() = p.getName() and
  p.getSource().isUserInput()
select call, "Potential path injection via uncontrolled data in path expression"