import python

/** @predicate */
from Call call, Function function
where
  call.getFunction() = function
  and function.getName() in ["input", "raw_input"]
  and not exists (Call c where c.getArgument(0) and c.getFunction().getName() = "int" and c.getFunction().getContainingFile() = call.getContainingFile())
select call.getLocation(), "Potential CWE-20: Improper Input Validation - Unvalidated input from user"