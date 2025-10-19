import python

from ParameterValue param, Call call
where param.getSource() = httpRequest.getParameter(...)
  and call.getTarget() = "print"
  and call.getArgument(0).getExpression() = param
select call, param