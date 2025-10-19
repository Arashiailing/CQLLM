import python

/**
 * CWE-264: Permissions, Privileges, and Access Controls
 * This query detects the CWE-264 vulnerability in Python code.
 */

from FunctionCall call, Function func
where func.getName() = "os.system"
  and call.getTarget() = func
select call, "Potential CWE-264 vulnerability: Use of os.system with user input."