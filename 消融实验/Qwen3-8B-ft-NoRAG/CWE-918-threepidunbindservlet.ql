import python

from Call call
where call.getFunction().getName() = "get"
  and call.getFunction().getModule() = "requests"
  and call.getArg(0).getExpression().hasUserInput()
select call, "Potential SSRF vulnerability: user-controlled URL used in HTTP request"