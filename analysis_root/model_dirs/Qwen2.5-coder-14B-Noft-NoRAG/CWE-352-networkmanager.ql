import python

/**
 * Detects potential CSRF protection issues in URL redirections.
 */
from Call call, Argument arg
where call.getCallee().getName() = "redirect" and
      arg = call.getArgument(0) and
      arg.getType().asString() = "str"
select call, "This call to'redirect' may be vulnerable to CSRF attacks because it does not include CSRF protection."