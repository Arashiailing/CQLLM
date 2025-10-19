import python

/**
 * A query to detect CWE-94: Command Injection vulnerability in Python code.
 */
from Call call, StringLiteral strLit
where call.getCallee().getName() = "subprocess.call" and
      call.getArgument(0) = strLit and
      not strLit.isSanitized()
select call, "Potential command injection vulnerability detected."