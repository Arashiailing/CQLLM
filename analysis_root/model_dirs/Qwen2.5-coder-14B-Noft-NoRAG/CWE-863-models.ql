import python

/**
 * CWE-863: Incorrect Authorization
 *
 * This query detects instances where an authorization check is performed,
 * but the check is not correctly implemented.
 */

from Call call, Function func
where func.getName() = "check_authorization" and
      call.getCallee() = func and
      not call.getArgument(0).isConstant() and
      not call.getArgument(1).isConstant()
select call, "Incorrect authorization check detected. Ensure that the arguments are properly validated."