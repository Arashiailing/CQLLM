import python

/**
 * A query to detect reflected server-side cross-site scripting (XSS) vulnerabilities.
 */
from WebRequest req, WebResponse res, Expr userInput, Expr outputExpr
where
  // Check if the user input is directly written to the response.
  req.getParameterValue(userInput) = outputExpr and
  // Check if the output expression is part of the response content.
  res.getContent() = outputExpr
select outputExpr, "Reflected XSS vulnerability detected: User input is directly written to the response."