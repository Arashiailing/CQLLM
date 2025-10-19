import py

/**
 * @name CWE-918: Server-Side Request Forgery (SSRF)
 * @description Detects potential SSRF vulnerabilities by identifying network requests to user-controlled URLs.
 */
from Call call, Argument arg
where call.getFunction().getName() = "get" and call.getFunction().getModule().getName() = "requests"
  and arg.getArgumentPosition() = 0
  and arg.getSource().getKind() = "userInput"
select call, "Potential SSRF vulnerability: User-controlled URL in requests.get() without validation."

from Call call, Argument arg
where call.getFunction().getName() = "post" and call.getFunction().getModule().getName() = "requests"
  and arg.getArgumentPosition() = 0
  and arg.getSource().getKind() = "userInput"
select call, "Potential SSRF vulnerability: User-controlled URL in requests.post() without validation."

from Call call, Argument arg
where call.getFunction().getName() = "request" and call.getFunction().getModule().getName() = "urllib.request"
  and arg.getArgumentPosition() = 0
  and arg.getSource().getKind() = "userInput"
select call, "Potential SSRF vulnerability: User-controlled URL in urllib.request.urlopen() without validation."