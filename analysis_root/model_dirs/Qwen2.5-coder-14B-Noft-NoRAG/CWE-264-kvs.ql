import python

/**
 * This query detects CWE-264: Command Injection vulnerability in Python code.
 */
from CallExpr call, StringLiteral str
where call.getCallee().getName() = "os.system" and
      call.getArgument(0) = str and
      str.getValue().contains("$") or str.getValue().contains("`") or str.getValue().contains("&")
select call, "Potential command injection vulnerability detected. The string literal passed to os.system may contain user input or special characters that could lead to command injection."