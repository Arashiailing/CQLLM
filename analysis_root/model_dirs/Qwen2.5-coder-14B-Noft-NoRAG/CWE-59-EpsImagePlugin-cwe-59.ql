import python

/**
 * This query detects CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * in Python code.
 */

from File file, Call call, Expr arg
where call.getCallee().getName() = "open"
  and arg = call.getArgument(0)
  and arg instanceof StringLiteral
  and arg.getStringValue() starts with "../"
select call, "This call to open() may be vulnerable to CWE-59 due to improper link resolution."