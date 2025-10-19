import py

from Call call, HttpParam param
where call.getTarget().getName() = "print" and
      call.getArgument(0).getExpression() = param
select call, param