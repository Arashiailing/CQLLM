import python

/**
 * CWE-601: URL Redirection to Untrusted Site ('Open Redirect')
 */
from CallExpr call, Expr urlExpr
where call.getCallee().getName() = "redirect_to" and
      call.getArg(0) = urlExpr and
      not urlExpr instanceof Literal
select urlExpr, "URL redirection based on unvalidated user input may cause redirection to malicious web sites."