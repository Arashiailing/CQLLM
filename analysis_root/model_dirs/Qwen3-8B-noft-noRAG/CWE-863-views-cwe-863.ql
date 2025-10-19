import python

/**
 * @name CWE-863: Incorrect Authorization
 * @description Detects potential incorrect authorization checks by looking for unauthenticated access to sensitive operations.
 */
from Call call, MemberAccess ma
where call.getTarget().getName() = "current_user" 
  and ma.getTarget().getName() = "has_perm" 
  and call.getFile().getPath() = ma.getFile().getPath()
  and call.getArg(0).getValue() = "anonymous"
select call, "Potential incorrect authorization: anonymous user has_perm without proper validation."