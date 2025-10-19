import python
import semmle.code.cpp.dataflow.DataFlow

from CallExpr call, Argument arg, FunctionDecl func
where 
  (func.getName() = "open" or func.getName() = "os.system" or func.getName() = "subprocess.check_output") and
  arg.getArgumentNumber() = 1 and
  arg.getExpression().hasSourceOfKind("UserInput")
select call, "Potential path injection due to unvalidated user input in file operation."