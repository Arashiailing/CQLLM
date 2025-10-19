import python

/**
 * A query to detect CWE-20: Command Injection vulnerabilities in Python.
 * This query looks for cases where user input is directly passed to system commands.
 */

from Call call, StringLiteral literal
where call.getCallee().getName() = "system"
  and call.getArgument(0) = literal
select call, "Potentially vulnerable system call: " + literal.getValue()