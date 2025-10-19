import python

/**
 * CWE-20: Command Injection
 * This query finds instances where user input is directly used in a system command
 * without proper validation or sanitization.
 */

from CallExpr call, StringLiteral cmd, Expr userInput
where call.getCallee().getName() = "subprocess.call" and
      call.getArgument(0) = cmd and
      exists(Expr inputExpr | inputExpr.getAChild() = userInput and
             userInput instanceof CallExpr and
             userInput.getCallee().getName() = "input")
select call, "Potentially vulnerable to command injection: user input is directly used in a system command."