import python

/**
 * This query detects CWE-287: Improper Authentication.
 * It identifies instances where authentication is not properly verified.
 */

from FunctionCall fc
where fc.getCallee().getName() = "pam_authenticate"
  and not exists(Call call | call.getCallee().getName() = "pam_acct_mgmt" and call.getAncestor() = fc)
select fc, "Potential CWE-287: Improper Authentication detected. The authentication is not properly verified."