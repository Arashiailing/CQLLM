import python

/**
 * A query to detect CWE-94: Code Injection vulnerabilities in Python code.
 */
from CallExpr call, StringLiteral strLit
where call.getCallee().getName() = "exec" or call.getCallee().getName() = "eval"
  and call.getArgument(0) = strLit
select strLit, "Unsanitized user input is being interpreted as code, which can lead to code injection."