import semmle.codeql.python.Python

from PyFunctionCall call
where call.getFunction().getName() = "open"
  and call.getArgument(0).getValue().contains("..")
select call, "Potential Path Traversal in open call"

from PyFunctionCall call
where call.getFunction().getName() = "os.system"
  and call.getArgument(0).getValue().contains("..")
select call, "Potential Path Traversal in os.system call"

from PyFunctionCall call
where call.getFunction().getName() = "os.execve"
  and call.getArgument(0).getValue().contains("..")
select call, "Potential Path Traversal in os.execve call"

from PyFunctionCall call
where call.getFunction().getName() = "os.path.join"
  and (call.getArgument(0).getValue().contains("..") or
       call.getArgument(1).getValue().contains(".."))
select call, "Potential Path Traversal in os.path.join call"