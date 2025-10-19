import python

/**
 * Query to detect Reflected XSS vulnerabilities in Python web applications.
 */
from WebRequest req, Expr userInput, Expr templateExpr
where
  // Check if the request is a web request
  req instanceof WebRequest and
  // Find user input from the request
  userInput = req.getUserInput() and
  // Find a template expression that uses the user input
  templateExpr = userInput.getAnAccess() and
  // Check if the template expression is used to render a response
  templateExpr.getAnAccess() instanceof HttpResponse
select
  templateExpr,
  "Potential Reflected XSS vulnerability detected. User input is directly used in a template expression."