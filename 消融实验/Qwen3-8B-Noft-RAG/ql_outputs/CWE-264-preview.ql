import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.python.security.dataflow.PermissionCheck

from CallNode call, String arg
where call.getFunction().getName() = "os.system" and
      arg = call.getArg(0) and
      PermissionCheck::missingPermissionCheck(arg)
select call, "Potential CWE-264: Missing permission check for os.system call"