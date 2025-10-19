import python

/**
 * This query detects the CWE-352: Server-Side Request Forgery (CSRF) vulnerability
 * by looking for the disabling or weakening of CSRF protection in Python web applications.
 */

from FunctionCall call, Variable var
where call.getCallee().getName() = "disable_csrf_protection" or
      call.getCallee().getName() = "weaken_csrf_protection"
select call, "CSRF protection is disabled or weakened here."