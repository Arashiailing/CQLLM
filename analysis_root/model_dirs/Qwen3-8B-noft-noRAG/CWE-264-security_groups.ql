import python
import semmle.code.java.DataFlow
import semmle.code.python.security.PermissionChecks

from Module m, FunctionDecl fd, CallExpr ce
where
  m.hasName("security_groups") and 
  fd.isPublic() and 
  ce.getFunction().hasName("check_permission") and 
  ce.getArgument(0).getExpression().toString().matches(".*request\.user") and 
  ce.getArgument(1).getExpression().toString().matches(".*resource_id")
select ce, "Potential CWE-264: Direct object reference detected in permission check"