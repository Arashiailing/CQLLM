import python

/**
 * Detects instances of CWE-74: Server Side Template Injection (SSTI) in Python.
 * This query looks for user-controlled data being used to render templates.
 */

from Call call, Expr userInput, Expr templateExpr
where call.getCallee().getName() = "render" and
      call.getArgument(0) = templateExpr and
      userInput instanceof ExternalData and
      templateExpr instanceof StringLiteral
select call, "Potentially vulnerable to SSTI due to user-controlled data in template rendering."