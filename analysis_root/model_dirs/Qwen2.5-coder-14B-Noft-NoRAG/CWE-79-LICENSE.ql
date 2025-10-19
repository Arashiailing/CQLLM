import python

/**
 * This query detects potential Reflected Cross-Site Scripting (XSS) vulnerabilities
 * in Python web applications. It looks for instances where user input is directly
 * written to a web page without proper sanitization.
 */

from WebRequest request, WebResponse response, Expr userInputExpr
where
  // Find a web request and response
  request.getResponse() = response and
  // Find an expression that represents user input
  userInputExpr instanceof UserInput and
  // Check if the user input is directly written to the response
  response.getBody().contains(userInputExpr)
select
  userInputExpr,
  "Potential Reflected XSS vulnerability: User input is directly written to the response."