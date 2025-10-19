import python

/** @predicate */
from Call call
where call.getMethodName() in ("has_perm", "is_allowed", "can", "check_permission", "authorize")
  and call.getArgumentCount() > 0
  // Check if the permission check is ignored or not properly enforced
  and exists(
    call.getCallsite().getLineNumber(),
    (Call c |
      c = call.getNextCall()
      and c.getMethodName() in ("save", "delete", "create", "update", "set_password", "change_password")
      and not c.hasExceptionHandling()
    )
  )
select call, "Potential CWE-863: Authorization check may be bypassed or improperly enforced"