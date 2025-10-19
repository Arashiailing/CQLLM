import python
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.strings.StringHandling

from CallExpr call, Argument arg, MethodDecl method
where 
  method.getName() = "join" and 
  method.getQualifier() = "os.path" and 
  call.getTarget() = method and 
  arg.getPosition() = 0 and 
  exists (Variable v, InputSource src | v.getValue().getExpression() = arg.getExpression() and src.getVariable() = v)
select call, "Potential path injection via os.path.join with untrusted input"