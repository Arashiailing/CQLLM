import python

/**
 * CWE-20: Improper Input Validation
 * This query detects potential Path Injection vulnerabilities in Python code.
 */

from Call call, StringLiteral fileParam
where call.getCallee().getName() = "open" and
      call.getArgument(0) = fileParam and
      not exists(StringLiteral safePath | safePath.getSubValue() = "/safe/path" and call.getArgument(0) = safePath)
select call, "This call to 'open' with a string literal argument may be vulnerable to path injection."