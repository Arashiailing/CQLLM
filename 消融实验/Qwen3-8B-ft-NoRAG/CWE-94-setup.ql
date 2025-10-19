import python

from Call call, Call inputCall
where call.getTarget().getName() = "eval" or call.getTarget().getName() = "exec"
  and call.getArg(0) = inputCall.getArg(0)
  and inputCall.getTarget().getName() = "input"
select call, "Potential code injection via eval/exec with user input"