import python

/**
 * This query detects CWE-20: Improper Input Validation
 * by finding function calls that do not validate input properly.
 */

from Call call, Function func
where func.getName() = "someFunctionThatProcessesInput"
  and not exists(call.getArgument(0).getAChild(*) instanceof If)
select call, "This function call does not validate input properly."