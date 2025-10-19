import python

/**
 * CWE-918: Server-Side Request Forgery (SSRF)
 */
from Call call, Argument arg
where call.getCallee().getName() = "requests.get" and
      arg = call.getArgument(0) and
      arg instanceof StringLiteral
select arg, "Potentially vulnerable to SSRF: User-controlled URL in request."