import python

/**
 * A query to detect CWE-78: Command Injection vulnerabilities in Python code.
 * This query looks for cases where user input is directly used in a system command.
 */

from CallExpr call, Arg arg
where call.getCallee().getName() = "subprocess.call" or call.getCallee().getName() = "os.system"
  and arg.getAPredecessor() instanceof UserInputExpr
select call, "Potentially vulnerable command execution due to uncontrolled input."