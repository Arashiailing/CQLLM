import python

/**
 * @name CWE-20: Template Injection
 * @description Detects improper input validation leading to template injection vulnerabilities.
 */
from Call call, Argument arg
where call.getCallee().getName() = "render_template" and
      arg.getArgumentIndex() = 0 and
      arg.getExpression().isVariable() and
      arg.getExpression().getVariable().isFromUserInput()
select call, "Potential Template Injection: Unvalidated template name parameter"