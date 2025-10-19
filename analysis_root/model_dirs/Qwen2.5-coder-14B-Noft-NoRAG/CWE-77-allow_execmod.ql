import python

/**
 * CWE-77: Command Injection
 */
from CallExpr call, StringLiteral cmd
where call.getCallee().getName() = "subprocess.Popen" and
      call.getArgument(0) = cmd and
      not exists(StringLiteral safeCmd | safeCmd.getValue() = cmd.getValue() and
                 safeCmd.getEnclosingFunction() instanceof Module)
select call, "This call to subprocess.Popen may be vulnerable to command injection."