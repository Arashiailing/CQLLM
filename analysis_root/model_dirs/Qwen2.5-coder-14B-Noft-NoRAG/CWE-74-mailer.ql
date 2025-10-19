import python

/**
 * CWE-74: Command Injection
 */
from Call call, Expr userControlledInput
where call.getCallee().getName() = "subprocess.Popen"
  and userControlledInput instanceof ExternalExpr
  and call.getArgument(0) = userControlledInput
select call, "Potential command injection vulnerability detected. User-controlled input is being used in a subprocess call."