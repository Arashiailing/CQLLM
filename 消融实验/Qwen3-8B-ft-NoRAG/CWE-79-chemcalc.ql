import python

from Call call, Parameter param
where call.getMethod().getName() = "print" and call.getArg(0).getValue().contains(param.getValue())
select call, "Potential reflected XSS vulnerability due to direct output of user input."