import python
import semmle.code.python.security.SecretOrPassword

from Call call, Parameter param
where call.getSelector().getName() in ("info", "debug", "warning", "error", "critical")
  and call.getModule().getName() = "logging"
  and exists (param = call.getParameter(i) for some i)
  and param.getSymbol().isSecret()
select call, "Potential CWE-532: Sensitive data logged in log statement."

import python
import semmle.code.python.security.SecretOrPassword

from Call call, Parameter param
where call.getSelector().getName() in ("info", "debug", "warning", "error", "critical")
  and call.getModule().getName() = "logging"
  and exists (param = call.getParameter(i) for some i)
  and param.getSymbol().isSecret()
select call, "Potential CWE-532: Sensitive data logged in log statement."