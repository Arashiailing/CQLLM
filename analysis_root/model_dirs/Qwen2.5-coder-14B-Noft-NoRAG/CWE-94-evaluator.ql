import python

/**
 * This query detects potential code injection vulnerabilities
 * by identifying calls to `eval` with user-controlled input.
 */
from Call call, Expr arg
where call.getCallee().getName() = "eval" and
      arg instanceof UserInput
select call, "This call to eval may be vulnerable to code injection."