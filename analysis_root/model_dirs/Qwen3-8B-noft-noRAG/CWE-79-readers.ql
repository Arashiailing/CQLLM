import semmle.python.Python

from CallExpr call, Expr arg
where call.getMethodName() = "format" and arg instanceof StringLiteral
select call, "Potential reflected XSS due to unescaped string formatting"