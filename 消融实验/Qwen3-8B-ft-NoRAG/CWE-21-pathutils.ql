import python

from CallExpr call, Argument arg, StringLiteral str
where call.getTarget().getName() = "os.path.join"
  and arg.getExpression() = str
  and str.getValue().matches(".*\.\./.*")
select call, "Potential Path Injection via os.path.join with directory traversal"