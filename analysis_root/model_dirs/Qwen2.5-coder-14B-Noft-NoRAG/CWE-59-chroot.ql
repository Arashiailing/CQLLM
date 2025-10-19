import python

/**
 * CWE-59: Improper Link Resolution Before File Access ('Link Following')
 */
from Call call, Argument arg, StringLiteral str
where call.getCallee().getName() = "open" and
      arg = call.getArgument(0) and
      str = arg.asExpr() and
      not exists(File file | file.getPath() = str.getValue())
select call, "This call to 'open' may be vulnerable to CWE-59: Improper Link Resolution Before File Access ('Link Following')."