import python

/**
 * CWE-77: Command Injection
 */
from CallExpr call, Expr cmdExpr, Expr userInput
where call.getCallee().getName() = "subprocess.call" or call.getCallee().getName() = "os.system"
  and call.getArgument(0) = cmdExpr
  and userInput instanceof UserInputExpr
  and cmdExpr.hasDescendant(userInput)
select call, "This call to subprocess.call or os.system may be vulnerable to command injection because it includes user input in the command string."