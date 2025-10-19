import python

/**
 * @name CWE-20: Improper Input Validation
 */
from CallExpr ce
where ce.getCallee() = "os.system"
   or (ce.getCallee() = "subprocess.run" and ce.getArg(0).getValue().toString().contains("shell=True"))
   or (ce.getCallee() = "subprocess.check_output" and ce.getArg(0).getValue().toString().contains("shell=True"))
   or (ce.getCallee() = "subprocess.call" and ce.getArg(0).getValue().toString().contains("shell=True"))
   or (ce.getCallee() = "subprocess.Popen" and ce.getArg(0).getValue().toString().contains("shell=True"))
select ce, "Potential CWE-20: Improper Input Validation - Command Injection Vulnerability detected"