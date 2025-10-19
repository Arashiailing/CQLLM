import python

/**
 * A query to detect CWE-94: Code Injection vulnerabilities in Python code.
 */
from Call call, Expr arg
where call.getCallee().getName() = "exec" or call.getCallee().getName() = "eval"
  and arg = call.getArgument(0)
  and not arg instanceof StringLiteral
select arg, "Unsanitized user input is being interpreted as code, which can lead to code injection."