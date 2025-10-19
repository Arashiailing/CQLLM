import python

from CallExpr call, Expr arg
where call.getCallee().getName() = "redirect" and
      arg instanceof CallExpr and
      arg.getCallee().getName() = "get" and
      arg.getArgument(0).getCallee().getName() = "request" and
      arg.getArgument(0).getArgument(0).getCallee().getName() = "input"
select call, "Potential CWE-601: URL redirection from remote source"