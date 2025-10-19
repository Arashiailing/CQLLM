import python

/**
 * CWE-20: Improper Input Validation
 * This query detects potential issues where input is not properly validated.
 */

from Function f, Call call, Expr arg
where f.getName() = "processInput"
  and call.getCallee() = f
  and arg = call.getArgument(0)
  and not exists(Expr validation | validation = arg.getAChild() and validation instanceof IfStmt)
select arg, "This input is not validated before processing."