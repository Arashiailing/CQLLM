import python

/**
 * @name CWE-20: Improper Input Validation (Command Injection)
 * @description Detects command injection vulnerabilities caused by improper validation of user-controlled inputs in system command execution.
 */
from CmdExecCall call, StringLiteral cmd, Expr inputExpr
where
  // Match common command execution functions
  (call.fun.name = "subprocess.run" or call.fun.name = "subprocess.call" or 
   call.fun.name = "subprocess.Popen" or call.fun.name = "os.system") and
  
  // Check if the command contains a user-controlled input expression
  exists(Param p | call.params[p.pos] = inputExpr and
         (p.type is StringType or p.type is ListType) and
         (inputExpr.hasUserInput() or inputExpr.isDynamic()))
  
  // Optional: Add checks for missing input sanitization
  and not exists(FilterNode f | f.parent = inputExpr and
                    f.kind = "Sanitize" or f.kind = "Escape")
select call.loc, "Potential command injection vulnerability due to unvalidated input in command execution", call