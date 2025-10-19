import python

/**
 * CWE-20: Command Injection
 * Detects potential command injection vulnerabilities in Python code.
 */

from CallExpr call, StringLiteral strLit
where call.getCallee().getName() = "subprocess.Popen" and
      call.getArgument(0) = strLit and
      not exists(StringLiteral safeStr | safeStr.getValue() = strLit.getValue() and safeStr.isSafe())
select call, "Potentially vulnerable to command injection."