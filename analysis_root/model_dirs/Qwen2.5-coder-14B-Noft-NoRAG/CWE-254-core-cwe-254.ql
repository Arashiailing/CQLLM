import python

/**
 * CWE-254: Code Injection
 * This query detects potential code injection vulnerabilities in Python code.
 */

from CallExpr call, StrLiteral strLit
where call.getCallee().getName() = "eval" and call.getArgument(0) = strLit
select call, "Potential code injection vulnerability detected: eval is called with a string literal."