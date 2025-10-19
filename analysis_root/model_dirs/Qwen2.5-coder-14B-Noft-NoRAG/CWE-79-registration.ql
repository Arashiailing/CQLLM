import python

/**
 * A query to detect CWE-79: Reflected Cross-Site Scripting (XSS) in Python web applications.
 * This query looks for cases where user input is directly written to the response without proper sanitization.
 */

from WebRequest req, WebResponse res, Expr userInput, Expr outputExpr
where
  // Find a web request and response
  req.getOutput() = res and
  // Find user input in the request
  userInput instanceof UserInput and
  // Find an expression that writes to the response
  outputExpr instanceof WebOutput and
  // Check if the user input is directly written to the response
  outputExpr.getArg(0) = userInput
select
  outputExpr,
  "This web response directly echoes user input, which may lead to Reflected XSS."