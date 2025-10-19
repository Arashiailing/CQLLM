import python

/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Detects potential exposure of sensitive information via logging.
 */

from LoggingCall c, Argument arg
where 
  c.getFunctionName() in ["debug", "info", "warning", "error", "critical"] and
  c.getSourceModule() = "logging" and
  arg.isStringFormatArgument() or 
  arg.isVariableReference()
select c.getLocation(), "Potential exposure of sensitive information via logging"