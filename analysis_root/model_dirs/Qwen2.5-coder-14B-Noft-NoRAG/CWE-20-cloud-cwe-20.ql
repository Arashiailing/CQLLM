import python

/**
 * This query detects potential Command Injection vulnerabilities
 * by identifying cases where user input is directly used in a
 * shell command without proper validation.
 */

from Call call, Expr inputExpr, Expr cmdExpr
where call.getCallee().getName() = "subprocess.call"
  and call.getArgument(0) = cmdExpr
  and exists(Expr userInput | userInput instanceof UserInput and cmdExpr.getSubExprs().contains(userInput))
select call, "Potential Command Injection vulnerability detected. User input is directly used in a shell command without proper validation."