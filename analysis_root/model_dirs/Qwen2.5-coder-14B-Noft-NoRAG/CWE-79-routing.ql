import python

/**
 * Detects instances of reflected cross-site scripting (XSS) vulnerabilities.
 * This query looks for cases where user input is directly written to a web page.
 */
from HttpRequest req, HttpResponse res, Expr userInputExpr, Expr outputExpr
where
  // Check if the request contains user input
  req.hasBody() and
  userInputExpr = req.getBody() and

  // Check if the response directly outputs the user input
  outputExpr = res.getBody() and
  userInputExpr = outputExpr
select
  req,
  "Reflected XSS vulnerability detected: User input is directly written to the response."