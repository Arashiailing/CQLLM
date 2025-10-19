import python

/**
 * CWE-19: Command Injection
 * Detects potential command injection vulnerabilities in Python code.
 */

from CallExpr call, StringLiteral strLit
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.Popen" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen" or
      call.getCallee().getName() = "os.exec" or
      call.getCallee().getName() = "os.spawn" or
      call.getCallee().getName() = "os.startfile"
  and strLit = call.getArgument(0)
select strLit, "Potential command injection vulnerability detected. User input should not be directly included in shell commands."