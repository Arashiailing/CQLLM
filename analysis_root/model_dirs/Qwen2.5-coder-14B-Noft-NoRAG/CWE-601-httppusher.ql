import python

/**
 * This query detects CWE-601: URL Redirection to Untrusted Site
 * It looks for HTTP redirections where the URL is derived from user input
 * without proper validation.
 */

from HttpRequest request, HttpResponse response, Expr userInputExpr
where
  // Check if the response is a redirection
  response.getStatusCode() = 302 or
  response.getStatusCode() = 301 or
  response.getStatusCode() = 303 or
  response.getStatusCode() = 307 or
  response.getStatusCode() = 308 and
  // Check if the Location header is set
  response.hasHeader("Location") and
  // Find the Location header value
  response.getHeaderValue("Location") = userInputExpr
select
  userInputExpr,
  "This URL redirection is based on unvalidated user input and may cause redirection to malicious web sites."