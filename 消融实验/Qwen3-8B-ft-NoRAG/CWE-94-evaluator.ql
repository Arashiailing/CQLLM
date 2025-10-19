import py

from PyFunctionCall call
where call.getName() = "eval" or call.getName() = "exec"
and call.getArgument(0).getType().isString()
select call, "Potential code injection via eval/exec with untrusted input"