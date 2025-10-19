import python

from CallExpr call
where call.getTarget().getName() = "str.format"
  or call.getTarget().getName() = "format"
  or call.getTarget().getName() = "eval"
  or call.getTarget().getName() = "exec"
select call, "Potential buffer overflow or format string vulnerability"