import python

/**
 * CWE-59: Improper Link Resolution Before File Access ('Link Following')
 */
from File file, Call call, StringLiteral literal
where call.getCallee().getName() = "open"
  and call.getArgument(0) = literal
  and file.getAPath() = literal.getValue()
select call, "This call to open may be vulnerable to CWE-59: Improper Link Resolution Before File Access ('Link Following')."