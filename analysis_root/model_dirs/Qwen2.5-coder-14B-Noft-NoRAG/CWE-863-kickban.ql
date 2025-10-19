import python

/**
 * Detects CWE-863: Incorrect Authorization
 */
from Call call, Function func
where func.getName() = "authorize"
  and call.getCallee() = func
  and not call.getArgument(0).getType().hasName("User")
select call, "This authorization check does not correctly verify the user."