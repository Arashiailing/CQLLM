import py

from Call call
where call.getMethodName() = "set_header" or call.getMethodName() = "add_header" or call.getMethodName() = "headers.__setitem__"
and call.getArg(0).getBase().getName() = "request"
and call.getArg(0).getMethod() in ("args", "form", "cookies")
select call, "Potential HTTP header injection via direct user input usage"