import python

from Call call
where call.getTarget().getName() = "authenticate"
  and call.getArgumentCount() > 0
  and not exists (call.getReturnStmt())
select call, "Potential CWE-287: Improper authentication due to lack of validation on authenticate call."