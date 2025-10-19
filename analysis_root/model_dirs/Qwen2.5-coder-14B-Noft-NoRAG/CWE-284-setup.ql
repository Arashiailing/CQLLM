import python

/**
 * CWE-284: Improper Access Control
 * Detects command injection vulnerabilities in Python code.
 */
from Call call, Function func
where func.getName() = "os.system" or func.getName() = "subprocess.call" or func.getName() = "subprocess.Popen"
  and call.getTarget() = func
  and call.getArgument(0) instanceof StrLiteral
select call, "Potential command injection vulnerability detected."