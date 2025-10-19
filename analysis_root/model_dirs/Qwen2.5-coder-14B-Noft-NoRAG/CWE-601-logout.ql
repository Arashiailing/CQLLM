import python

/**
 * Detects CWE-601: URL redirection from remote source
 * URL redirection based on unvalidated user input
 * may cause redirection to malicious web sites.
 */
from RequestHandler handler, Expr userInput, Expr redirectUrl
where handler.getMethod() = "GET" and
      handler.hasParameter(userInput) and
      redirectUrl = handler.getParameterValue(userInput) and
      not handler.validatesInput(userInput)
select redirectUrl, "Potential URL redirection from unvalidated user input"