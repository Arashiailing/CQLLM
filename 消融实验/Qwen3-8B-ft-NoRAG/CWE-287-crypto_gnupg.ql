import python

/** @name Path Injection */
from Call call, Argument arg
where call.getMethod().getName() = "open" or call.getMethod().getName() = "os.path.join" or call.getMethod().getName() = "pathlib.Path"
  and arg.getValue().getKind() = "stringLiteral"
  and arg.getValue().getValue().contains("..")
select call, "Potential Path Injection via unvalidated path traversal sequence"