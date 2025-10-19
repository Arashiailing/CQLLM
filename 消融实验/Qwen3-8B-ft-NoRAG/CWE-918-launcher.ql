import python
import semmle.code.cpp.dataflow.DataFlow

from MethodCall call, Argument arg
where
  call.getMethodName() = "get" or call.getMethodName() = "post" or
  call.getMethodName() = "request" or call.getMethodName() = "urlopen"
  and call.getModule().getName() = "requests" or call.getModule().getName() = "urllib.request"
  and arg.getArgumentPosition() = 0
  and arg.getValue().isUserInput()
select call, "Potential SSRF vulnerability: User-controlled URL used in HTTP request"