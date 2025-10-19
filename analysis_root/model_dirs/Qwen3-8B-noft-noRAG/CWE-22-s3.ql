import python
import semmle.code.cpp.dataflow.DataFlow

from CallExpr call, Argument arg, File f
where 
  call.getMethodName() = "join" and 
  arg.getArgumentPosition() = 0 and 
  arg.getValue().getValue() = f.getPath()
  or 
  call.getMethodName() = "join" and 
  arg.getArgumentPosition() = 1 and 
  arg.getValue().getValue() = f.getPath()
select call, "Uncontrolled data used in path expression"

import python
import semmle.code.cpp.dataflow.DataFlow

/**
 * Find instances where untrusted input is used in a file path construction
 */
from CalledMethod cm, Arg arg, MethodInvoke mi
where 
  (cm.getName() = "os.path.join" or cm.getName() = "pathlib.Path.__add__") and
  exists(DataSource ds | ds.getOutput() = arg.getValue()) and
  mi.getMethodName() in ("open", "read", "write", "exec") and
  mi.getArg(0).getValue().getExpression() = cm.getThis() and
  mi.getArg(1).getValue().getExpression() = arg.getValue()
select mi, "Potential Path Traversal/Injection vulnerability detected: untrusted input used in path construction"