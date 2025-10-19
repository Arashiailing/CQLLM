import python

/**
 * CWE-601: URL Redirection to Untrusted Site ('Open Redirect')
 *
 * This query detects instances where user input is used to construct a URL for redirection
 * without proper validation.
 */

from HttpRequest req, HttpRedirectResponse resp, Expr userInputExpr
where req.getRedirectUrl() = resp.getUrl() and
      userInputExpr instanceof Call and
      userInputExpr.getCallee().getName() = "input" and
      userInputExpr.getAnArgument(0) = req.getParameter("url")
select resp, "This URL redirection is based on unvalidated user input and may lead to open redirect vulnerabilities."