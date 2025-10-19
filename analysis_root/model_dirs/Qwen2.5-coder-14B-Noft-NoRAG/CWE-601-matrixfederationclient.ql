import python

/**
 * CWE-601: URL Redirection to Untrusted Site ('Open Redirect')
 *
 * This query finds instances where user input is used to construct a URL
 * for redirection without proper validation.
 */

from Call call, Expr userInput, Expr redirectUrl
where call.getCallee().getName() = "redirect" and
      call.getArgument(0) = userInput and
      not exists(Expr validation |
          validation instanceof Call and
          validation.getCallee().getName() = "validateUrl" and
          validation.getArgument(0) = redirectUrl)
select call, "Unvalidated user input is used to construct a URL for redirection."