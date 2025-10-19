import python

from InputString src, Call call
where 
  src = InputString("input") and 
  call.getTarget().getName() = "eval" and 
  call.getArgument(0).getSymbol() = src.getValue()
select call, "Potential CWE-20: Improper Input Validation - Unvalidated input passed to eval"