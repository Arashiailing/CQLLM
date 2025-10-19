import python

/**
 * This query detects instances where CSRF protection is weakened or disabled.
 */
from Call call, Argument arg
where call.getCallee().getName() = "disable_csrf_protection" or
      call.getCallee().getName() = "weaken_csrf_protection"
select arg, "CSRF protection is disabled or weakened here."