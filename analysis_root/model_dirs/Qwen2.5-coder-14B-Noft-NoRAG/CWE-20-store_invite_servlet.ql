import python

/**
 * This query detects CWE-20: Improper Input Validation
 * in Python code by looking for calls to system commands
 * without proper input validation.
 */

from Call call, StringLiteral strLit
where call.getCallee().getName() = "subprocess.call"
  and call.getArgument(0) = strLit
select call, "Potential command injection vulnerability due to improper input validation."