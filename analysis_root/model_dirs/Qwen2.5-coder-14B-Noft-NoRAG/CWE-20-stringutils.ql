import python

/**
 * CWE-20: Improper Input Validation
 * This query detects instances where input is received but not properly validated.
 */

from Function func, Call call, StringLiteral strLit
where func.getName() = "input"
  and call.getCallee() = func
  and not exists(StringValidation validation | validation.getArg() = call.getArgument(0))
select call, "This function call receives input but does not validate it properly."