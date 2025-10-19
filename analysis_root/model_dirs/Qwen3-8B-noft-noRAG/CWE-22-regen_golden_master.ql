import python
import semmle.code.cpp.dataflow.DataFlow

from CallExpr call, Argument arg
where 
  call.getQualifiedName() = "os.path.abspath" and
  arg.getPosition().getModule().getFile().getName() = "example.py"
select call, "Potential path injection via os.path.abspath"