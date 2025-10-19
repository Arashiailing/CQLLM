import python
import semmle.python.security.xss

/**
 * CWE-684: Reflected XSS
 * This query detects instances where user input is directly reflected in the output without proper sanitization.
 */

from HttpRequest req, HttpResponse res, Expr userInput, Expr outputExpr
where
  // Find HTTP requests and responses
  req.getResponses() = res and
  // Find user input expressions (e.g., request parameters)
  userInput instanceof HttpRequestParameter and
  // Find output expressions (e.g., response content)
  outputExpr instanceof HttpResponseContent and
  // Check if user input is directly used in the output
  userInput = outputExpr
select
  outputExpr,
  "Reflected XSS vulnerability detected: User input is directly reflected in the output without proper sanitization."