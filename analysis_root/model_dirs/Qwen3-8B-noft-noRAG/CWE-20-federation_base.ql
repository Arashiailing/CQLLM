import python

/**
 * Detects potential command injection vulnerabilities by identifying dangerous function calls
 * that directly use untrusted inputs without proper validation.
 */
from CallExpr call, String s
where (call.getMethod().getName() = "run" and call.getCallee().getQualifiedName() = "subprocess") or
      (call.getMethod().getName() = "system" and call.getCallee().getQualifiedName() = "os") or
      (call.getMethod().getName() = "exec" and call.getCallee().getQualifiedName() = "os") or
      (call.getMethod().getName() = "Popen" and call.getCallee().getQualifiedName() = "subprocess")
and call.getArgument(0).getValue().equals(s)
and s.isUntrustedInput()
select call, "Potential command injection vulnerability detected: Untrusted input used directly in system command execution."