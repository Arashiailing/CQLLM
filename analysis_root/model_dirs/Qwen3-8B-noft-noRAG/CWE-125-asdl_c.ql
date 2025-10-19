import python
import semmle.code.cpp.dataflow.DataFlow

from Call call, StringLiteral strLit, Parameter param
where 
  call.getTarget().getName() = "system" and
  call.getArgument(0).getExpression() instanceof CallExpr and
  call.getArgument(0).getExpression().getAsString() = strLit.getValue() and
  strLit.getValue().contains("%") and
  param.getParameterName() = "args" and
  call.getSourceLocation().getFile().getName() = "example.py"
select call, "Potential Command Injection via system() with format string"