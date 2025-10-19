import python

/**
 * @name CWE-20: LogInjectionQuery
 * @description Detects potential log injection vulnerabilities
 * @id py/log_injection
 */

from CallExpr logCall, StringLiteral logString
where logCall.getCallee().getName() = "log" and
      logCall.getArgument(0) = logString and
      exists(StringInterpolation interpolation | interpolation.getContainer() = logString)
select logCall, "Potential log injection vulnerability detected due to string interpolation in log statement."