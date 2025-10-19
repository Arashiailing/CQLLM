import python

/**
 * A query to detect reflected server-side cross-site scripting (XSS) vulnerabilities.
 */
from Expr userInput, Expr outputExpr
where
  // Check if the user input is directly written to the output expression.
  userInput instanceof Call and
  outputExpr instanceof Call and
  userInput.getMethod().hasName("request") and
  outputExpr.getMethod().hasName("write") and
  userInput.getArgument(0) = outputExpr.getArgument(0)
select
  outputExpr,
  "This code writes user input directly to the output, which may lead to a reflected XSS vulnerability."