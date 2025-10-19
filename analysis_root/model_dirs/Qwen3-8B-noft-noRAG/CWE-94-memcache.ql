import py

from Call call
where call.getTarget().getName() = "eval" or call.getTarget().getName() = "exec"
select call, "Potential code injection via exec/eval"