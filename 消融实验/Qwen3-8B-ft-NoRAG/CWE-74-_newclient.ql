import python
import semmle.code.python.security.UserInput

from CallExpr call, Argument arg
where call.getCallee().getName() in ["render_template", "render", "template"]
  and arg.getArgumentPosition() = 0
  and arg.getExpression() is UserInput
select call, "Potential Server Side Template Injection"