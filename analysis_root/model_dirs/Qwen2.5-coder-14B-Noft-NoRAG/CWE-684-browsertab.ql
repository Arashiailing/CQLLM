import python

/**
 * @name CWE-684: Command Injection
 * @description Detects potential command injection vulnerabilities in Python code.
 * @id py/command-injection
 */

from Call call, Function func
where call.getCallee() = func and func.getName() = "subprocess.call" or func.getName() = "os.system"
select call, "This call to " + func.getName() + " may be vulnerable to command injection."