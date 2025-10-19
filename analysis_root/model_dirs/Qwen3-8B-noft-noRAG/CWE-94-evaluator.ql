import python

from Call call
where call.getFunction().getName() = "eval" or call.getFunction().getName() = "exec"
select call, "Potential code injection: use of eval or exec with potentially untrusted input"