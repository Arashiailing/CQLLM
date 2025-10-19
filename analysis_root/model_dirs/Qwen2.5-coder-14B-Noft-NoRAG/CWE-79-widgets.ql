import python

/**
 * Reflected server-side cross-site scripting (XSS) vulnerability.
 */
from WebRequest req, Expr userInput, Expr outputExpr
where
  // Find user input from a web request
  req.getUserInput(userInput) and
  // Find the output expression that writes to the web page
  outputExpr.getAChild() = userInput and
  // Ensure the output is directly to the web page
  outputExpr instanceof WebOutput
select outputExpr, "Reflected XSS vulnerability detected. User input is directly written to the web page."