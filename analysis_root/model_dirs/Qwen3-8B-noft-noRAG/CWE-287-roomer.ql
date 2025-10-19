import python

/**
 * @name CWE-287: Improper Authentication
 * @description Detects instances where authentication checks are bypassed or improperly implemented.
 */
from MethodInvocation authCheck, Call call
where
  authCheck.getMethod().getName() = "is_authenticated" and
  authCheck.getArgument(0).getType().getName() = "User" and
  call.getMethod().getName() = "has_perm" or
  call.getMethod().getName() = "has_module_perms" or
  call.getMethod().getName() = "has_obj_perm"
select call, "Potential improper authentication: Missing or bypassed authentication check."