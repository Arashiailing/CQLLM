import python

/**
 * @name CWE-863: Incorrect Authorization
 * @description Detects cases where authorization checks are missing around stream operations.
 */
from Call c, Function f
where 
  (c.getSelector().getName() = "read" or c.getSelector().getName() = "write" or c.getSelector().getName() = "open") 
  and c.getArg(0).getType().getName() = "str" 
  and not exists (c.getEnclosingMethod().getStatements(), stmt |
    stmt.isIfStatement() and stmt.getText().contains("check_permissions") or
    stmt.getText().contains("authorize") or
    stmt.getText().contains("has_access"))
select c, "Potential Incorrect Authorization: Missing check for stream operation on file path '$path'",
  {c.getArg(0).getValue()} as path