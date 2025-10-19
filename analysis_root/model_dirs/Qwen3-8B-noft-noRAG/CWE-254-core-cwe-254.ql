import python

from CallExpr call
where call.getTarget().getName() in ("eval", "exec")
select call, message("Potential code injection via eval/exec")