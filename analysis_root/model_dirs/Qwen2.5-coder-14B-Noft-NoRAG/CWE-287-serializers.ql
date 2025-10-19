import python

/**
 * This query detects CWE-287: Improper Authentication
 * by looking for instances where authentication is not properly verified.
 */

from Call call, Function func
where func.getName() = "authenticate" and
      not exists(call.getArgument(0).getType().getSubTypes().hasName("AuthenticatedUser"))
select call, "This authentication call does not properly verify the user identity."