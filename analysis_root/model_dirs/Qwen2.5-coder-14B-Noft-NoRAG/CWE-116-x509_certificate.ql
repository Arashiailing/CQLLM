import python

/**
 * This query detects potential Log Injection vulnerabilities by looking for
 * instances where user input is directly logged without proper sanitization.
 */

from StringLiteral logFormat, CallExpr logCall, Expr userInput
where logCall.getCallee().getName() = "log" and
      logCall.getArgument(0) = logFormat and
      logFormat.getValue() =~ /%.*%/ and
      userInput = logCall.getArgument(1) and
      not exists(Sanitization sanitization | sanitization.getSanitized() = userInput)
select logCall, "Potential Log Injection vulnerability: User input is logged without sanitization."