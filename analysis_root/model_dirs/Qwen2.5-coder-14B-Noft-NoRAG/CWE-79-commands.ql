import python

/**
 * A query to detect CWE-79: Reflected Cross-Site Scripting (XSS) in Python web applications.
 * This query looks for instances where user input is directly written to a web page without proper sanitization.
 */

from WebRequest req, WebResponse res, Expr userInput, Expr outputExpr
where
  // Find web requests and responses
  req.getKind() = "GET" and
  res.getWebRequest() = req and

  // Find user input in the request
  userInput instanceof Call and
  userInput.getCallee().getName() = "get" and
  userInput.getArgument(0).toString() = "user_input" and

  // Find the expression that outputs the user input to the response
  outputExpr instanceof Expr and
  outputExpr.getAChild() = userInput and
  outputExpr.getAParent() instanceof ReturnStmt and
  outputExpr.getAParent().getParent() instanceof Function and
  outputExpr.getAParent().getParent().getName() = "render"

select outputExpr, "Reflected XSS vulnerability detected: User input is directly written to the web page without proper sanitization."