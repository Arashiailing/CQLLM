import python

/**
 * Detects potential exposure of sensitive information via logging.
 */
from CallExpr call, StringLiteral msgLit
where call.getBase().getName() = "info" or 
      call.getBase().getName() = "debug" or 
      call.getBase().getName() = "warning" or 
      call.getBase().getName() = "error" or 
      call.getBase().getName() = "critical"
  and call.getArg(0) = msgLit
  and (msgLit.getValue().matches(".*\$\{.*\}.*") or 
       msgLit.getValue().matches(".*f\"\$.*\".*"))
select call, "Potential CWE-200: Sensitive information may be exposed through log messages."