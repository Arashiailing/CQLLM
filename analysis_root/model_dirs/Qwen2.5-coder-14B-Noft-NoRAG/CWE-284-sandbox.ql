import python

/**
 * Detects potential command injection vulnerabilities in Python code.
 */
from Call call, Expr commandExpr
where call.getCallee().getName() = "subprocess.call" and
      commandExpr = call.getArgument(0)
select commandExpr, "This call to subprocess.call may be vulnerable to command injection."