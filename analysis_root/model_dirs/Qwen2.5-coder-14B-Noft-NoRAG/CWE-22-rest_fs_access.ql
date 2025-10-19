import python

/**
 * This query detects instances of CWE-22: Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection').
 */
from Call call, Arg arg, StringVal path
where call.getCallee().getName() = "open" and
      arg = call.getArgument(0) and
      arg = path
select arg, "Uncontrolled data used in path expression"