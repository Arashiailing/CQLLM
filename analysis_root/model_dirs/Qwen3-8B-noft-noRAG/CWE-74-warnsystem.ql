import python
import semmle.code.cpp.dataflow.DataFlow

from MethodCall call, Argument arg, Parameter param
where 
  call.getMethodName() = "render_template_string" or 
  call.getMethodName() = "Template"
  and arg.getArgumentNumber() = 1
  and exists( (arg.getSourceLocation().getFile(), arg.getSourceLocation().getLine()) -> getDefinition() -> hasType("str") )
  and exists( (call.getExpression().getSourceLocation().getFile(), call.getExpression().getSourceLocation().getLine()) -> getDefinition() -> hasType("str") )
select call, "Potential Server Side Template Injection vulnerability: user-controlled data used in template rendering."