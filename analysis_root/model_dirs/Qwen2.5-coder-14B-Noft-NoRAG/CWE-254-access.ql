import python

/**
 * CWE-254: Code Injection
 * This query detects potential code injection vulnerabilities in Python code.
 */

from Call call, StringLiteral strLit
where call.getCallee().getName() = "exec" and
      call.getArgument(0) = strLit
select call, "Potentially vulnerable to code injection: exec() called with user-controlled input."