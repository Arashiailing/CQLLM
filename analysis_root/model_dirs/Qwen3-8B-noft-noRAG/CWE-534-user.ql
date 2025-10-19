import semmle.python.Python

/**
 * Detects the use of sensitive data in log messages.
 */
from LoggingCall call, StringLiteral lit
where (call.getName() = "debug" or call.getName() = "info" or call.getName() = "warn" or call.getName() = "error" or call.getName() = "critical") 
  and call.getParameter(0) = lit
  and lit.getValue().matches(".*password.*|.*secret.*|.*key.*|.*token.*|.*credentials.*|.*api_key.*|.*auth_token.*")
select call, "Sensitive data exposed in log message: " + lit.getValue()