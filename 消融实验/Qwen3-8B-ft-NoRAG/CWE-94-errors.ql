import py

from Call call, Call inputCall
where (call.getCallee().getName() = "eval" or call.getCallee().getName() = "exec")
  and inputCall.getCallee().getName() = "input"
  and call.getArg(0) = inputCall.getArg(0)
select call, "Potential code injection via eval/exec with user input from input() function."