import python

/**
 * @name LogInjection
 * @description Detects potential log injection vulnerabilities by identifying direct user input in logging statements.
 */
from Call call, Argument arg
where call.getSelector().getName() in ["debug", "info", "warning", "error", "critical"] 
  and call.getModule() = "logging"
  and arg.getExpression() is Variable
  and arg.getExpression().getName() in ["request", "input", "user", "session", "env", "args", "params"]
select call, "Potential Log Injection: User input directly logged without sanitization."