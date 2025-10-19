import python

/**
 * CWE-74: Command Injection
 */
from Call call, StringLiteral str
where call.getCallee().getName() = "os.system"
  and call.getArgument(0) = str
select call, "Potential command injection vulnerability due to user-controlled input in os.system call."