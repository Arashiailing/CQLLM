import python

/**
 * @name CWE-532: Cleartext Logging
 * @description Detects instances where sensitive information is logged directly.
 */
from FunctionCall call
where call.getCallee().getFullyQualifiedName().startsWith("logging.")
  and call.getName() in ("info", "debug", "warning", "error", "critical", "exception")
  and call.getArguments().size() > 0
  and exists(call.getArguments()[0].asStringLiteral())
select call, "Potential cleartext logging of sensitive information detected."