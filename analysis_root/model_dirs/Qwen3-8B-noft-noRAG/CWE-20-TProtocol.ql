import python

from Call call
where call.getCallee().getName() = "eval" or
      call.getCallee().getName() = "exec" or
      call.getCallee().getName() = "__import__"
select call, "Potential Code Injection due to improper input validation."