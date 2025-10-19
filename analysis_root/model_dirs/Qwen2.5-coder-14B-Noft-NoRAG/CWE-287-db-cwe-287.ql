import python

/**
 * CWE-287: Improper Authentication
 * Detects potential SQL injection vulnerabilities in Python code.
 */
from Function f, CallExpr call, StringLiteral sqlQuery
where f.getName() = "authenticate" and
      call.getTarget() = f and
      call.getArgument(0) instanceof StringLiteral and
      sqlQuery = call.getArgument(0).getValue()
select sqlQuery, "Potential SQL injection vulnerability detected in authentication function."