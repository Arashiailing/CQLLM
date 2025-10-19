import python

/**
 * @name CWE-269: Improper Privilege Management
 * @description Detects potential improper privilege management issues in Python code.
 */
from method m, Call c
where
  m.hasName("check_permissions") and
  c.getTarget() = m and
  exists(c.getArg(0) as expr, isLiteral(expr) and (expr.getValue().toString() = "admin" or expr.getValue().toString() = "root")) and
  not exists(c.getArg(1) as expr, expr.getType().getName() = "User" and expr.getName() = "role")
select c, "Potential improper privilege management: hardcoded admin/root check without proper user role validation"