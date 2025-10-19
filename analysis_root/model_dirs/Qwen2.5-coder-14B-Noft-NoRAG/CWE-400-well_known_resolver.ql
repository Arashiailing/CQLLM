import python

/**
 * CWE-400: ServerSideRequestForgeryQuery
 */
from Call call, Function func
where func.getName() = "requests.get" and
      call.getTarget() = func and
      call.getArgument(0) instanceof StringLiteral
select call, "This call to requests.get may be vulnerable to SSRF."