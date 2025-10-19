import python
import semmle.code.java.dataflow.DataFlow
import semmle.code.python.security.PathTraversal

from CallExpr call, Argument arg, FunctionDecl func
where 
  (func.getName() = "os.system" or 
   func.getName() = "subprocess.call" or 
   func.getName() = "subprocess.run") and
  arg.getArgumentPosition() = 0 and
  call.getTarget() = func and
  exists(DataFlow::PathTraversal vulnerability where vulnerability.getPath() = arg.toString())
select call, "Potential CWE-59: Improper link resolution before file access detected."