import python

/**
 * CWE-352: UrlRedirectQuery
 * Detects potential CSRF vulnerabilities by identifying URL redirection
 * functions that do not properly validate the CSRF token.
 */

from CallExpr call, Function func
where func.getName() = "redirect" and
      call.getTarget() = func and
      not exists(call.getArgument(0).getAChild() instanceof CSRFTokenCheck)
select call, "This URL redirection function does not validate the CSRF token."