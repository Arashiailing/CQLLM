import python

/**
 * This query detects reflected cross-site scripting (XSS) vulnerabilities in Python web applications.
 * It looks for cases where user input is directly written to the response without proper sanitization.
 */

from WebRequest req, WebResponse resp, Expr userInput, Expr outputExpr
where
  // Find a web request and response
  req.getResponse() = resp and

  // Find user input in the request
  userInput instanceof WebRequestParam and

  // Find an expression that writes to the response
  outputExpr instanceof WebResponseOutput and

  // Check if the user input is directly written to the response
  outputExpr.getExpr() = userInput
select
  outputExpr,
  "This expression directly writes user input to the response, which may lead to reflected XSS."