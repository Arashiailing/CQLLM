import python

/**
 * This query detects instances where CSRF protection is disabled or weakened.
 * It looks for code that disables or bypasses CSRF checks.
 */

from Call call
where call.getCallee().getName() = "disableCSRFProtection"
  or call.getCallee().getName() = "bypassCSRFCheck"
select call, "CSRF protection is disabled or weakened here."