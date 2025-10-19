import python

/**
 * CWE-601: URL Redirection to Untrusted Site ('Open Redirect')
 * This query detects cases where user input is used to construct a URL for redirection
 * without proper validation.
 */

from Call call, Argument arg, StringLiteral url
where call.getCallee().getName() = "redirect" and
      call.getArgument(0) = arg and
      arg.getValue() = url and
      not exists(Expr validator | arg.getAChild() = validator)
select call, "Potentially vulnerable URL redirection detected. User input is used to construct the redirection URL without validation."