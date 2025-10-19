import python
import semmle.code.cpp.dataflow.DataFlow

from MethodCall call, Argument arg
where call.getMethodName() = "render_template" and
      arg.getArgumentNumber() = 0 and
      arg.getExpression().getUsedVariables().exists(v | v.getKind() = "userInput")
select call, "Potential Server Side Template Injection: User-controlled data used in template rendering"