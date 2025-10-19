import python

/**
 * This query detects CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * by identifying instances where a symbolic link is followed without proper validation.
 */

from CallExpr call, Arg arg
where call.getCallee().getName() = "os.path.join"
  and arg = call.getArgument(0)
  and exists(CallExpr followLinkCall | followLinkCall.getCallee().getName() = "open"
              and followLinkCall.getArgument(0) = arg)
select call, "Potential CWE-59: Improper Link Resolution Before File Access detected."