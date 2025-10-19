import python

/**
 * This query detects potential command injection vulnerabilities in Python code.
 * CWE-94: Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection')
 */

from Call call, Expr cmdExpr
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.Popen" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen"
  and call.getArgument(0) = cmdExpr
  and not (exists(Expr sanitizedExpr | sanitizedExpr instanceof MethodCall and sanitizedExpr.getMethod().getName() = "shlex.quote" and sanitizedExpr.getArgument(0) = cmdExpr))
select call, "Potential command injection vulnerability detected. User input is directly used in an OS command."