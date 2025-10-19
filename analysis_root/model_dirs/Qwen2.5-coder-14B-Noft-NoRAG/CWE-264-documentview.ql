import python

/**
 * CWE-264: Path Traversal
 * Detects potential path traversal vulnerabilities in Python code.
 */
from File file, Call call, Expr pathExpr
where call.getCallee().getName() = "open" and
      call.getArgument(0) = pathExpr and
      pathExpr instanceof StringLiteral
select pathExpr, "Potential path traversal vulnerability detected: " + pathExpr.getValue()