import python

/**
 * CWE-20: Improper Input Validation
 * Detects potential path injection vulnerabilities in Python code.
 */
from Call call, StringLiteral path
where call.getCallee().getName() = "open" and
      call.getArgument(0) = path and
      not exists(StringLiteral safePath | safePath = path and
                  safePath.getValue() not matches ".*[\\x00-\\x1F\\x7F].*")
select call, "Potential path injection vulnerability detected. Validate input before using it in file operations."