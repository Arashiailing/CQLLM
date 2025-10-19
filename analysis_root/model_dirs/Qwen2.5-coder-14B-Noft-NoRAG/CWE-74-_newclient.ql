import python

/**
 * This query detects potential Reflected XSS vulnerabilities in Python code.
 * It looks for instances where user input is directly embedded into HTTP responses.
 */

from HttpRequest request, HttpResponse response, Expr userInputExpr, Expr httpResponseExpr
where
  // Find HTTP requests and responses
  request.getResponse() = response and
  // Find expressions that represent user input
  userInputExpr instanceof UserInput and
  // Find expressions that represent the HTTP response body
  httpResponseExpr instanceof HttpResponseBody and
  // Check if user input is directly embedded into the HTTP response body
  httpResponseExpr.getAChild*() = userInputExpr
select httpResponseExpr, "Potentially vulnerable to Reflected XSS: user input is directly embedded in the HTTP response."