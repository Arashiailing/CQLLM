import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.python.security.dataflow.PermissionCheck

from Call call, PermissionCheck::PermissionNode permission
where call.getFunction().getName() = "some_high_privilege_function" and
      PermissionCheck::hasMissingCheck(call, permission)
select call, "Potential CWE-264: Missing permission check for high privilege operation."