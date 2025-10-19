import python

/**
 * This query detects potential Reflected Cross-Site Scripting (XSS) vulnerabilities
 * in Python web applications. It looks for instances where user input is directly
 * written to a web page without proper sanitization or encoding.
 */

from Expr userInput, Expr outputExpr
where
  // Find user input expressions, such as request parameters
  userInput instanceof Call and
  userInput.getCallee().getName() = "request" and
  userInput.getArgument(0) instanceof StringLiteral and
  userInput.getArgument(0).getValue() = "GET" and
  // Find expressions that output data to the web page
  outputExpr instanceof Call and
  outputExpr.getCallee().getName() = "write" and
  // Check if the user input is directly used in the output expression
  outputExpr.getArgument(0) = userInput
select outputExpr, "This expression outputs user input directly to the web page, which may lead to a reflected XSS vulnerability."