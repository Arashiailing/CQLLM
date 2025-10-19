import python

/**
 * This query detects potential instances of CWE-444: Inconsistent Interpretation of HTTP Requests ('HTTP Request/Response Smuggling')
 * in Python code.
 */

from FunctionCall fc, Argument arg
where fc.getCallee().getName() = "write" and
      arg = fc.getArgument(0) and
      arg.getType().hasName("str")
select arg, "This argument might be vulnerable to HTTP Request/Response Smuggling due to inconsistent interpretation of HTTP requests."