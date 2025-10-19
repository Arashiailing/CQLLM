import semmle.code.cpp.FrameworksAndLibraries
import semmle.python.Python
import semmle.code.common.Message

from HttpParam param, Call call, Argument arg
where 
  call.getTarget().getName() = "print" and 
  arg.getArgumentPosition() = 0 and 
  arg.getExpression() = param and 
  param.getSource().getKind() = "request"
select call, "This call may be vulnerable to reflected XSS due to direct output of untrusted input."