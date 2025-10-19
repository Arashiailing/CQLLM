import python

/**
 * CWE-94: Code Injection
 * Detects instances where user input is interpreted as code.
 */
from Expr userInput, Expr codeExecution
where userInput.isTainted() and
      codeExecution instanceof EvalExpr and
      codeExecution.getArgument(0) = userInput
select codeExecution, "This code execution interprets unsanitized user input as code, which can lead to code injection."