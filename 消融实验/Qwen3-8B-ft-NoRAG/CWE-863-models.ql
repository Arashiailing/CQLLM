import python

/**
 * @name CWE-863: Incorrect Authorization
 * @description Detects potential incorrect authorization checks in Python code.
 */
from Call call
where call.getCallee().getName() = "check_permission" or
      call.getCallee().getName() = "has_permission" or
      call.getCallee().getName() = "authorize"
select call, "Potential incorrect authorization check detected."