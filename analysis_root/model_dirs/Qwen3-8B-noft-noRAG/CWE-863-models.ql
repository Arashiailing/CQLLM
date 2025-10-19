import python

/**
 * @name CWE-863: Incorrect Authorization
 * @description Detects potential incorrect authorization checks in Python code.
 */
from MethodCall mc
where mc.getMethodName() = "has_perm" or mc.getMethodName() = "has_perms" or mc.getMethodName() = "is_authenticated"
  and mc.getCallee().getFilePath()!= null
  and (mc.getArgument(0).getType().getName() = "User" or mc.getArgument(0).getType().getName() = "request")
  and mc.getArgument(1).getType().getName() = "str"
  and not (mc.getArgument(1).getValue().matches("^(?!.*\.\.)[a-zA-Z0-9_]+(\.[a-zA-Z0-9_]+)*$"))
select mc, "Potential incorrect authorization check detected."