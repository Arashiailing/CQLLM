import python

/**
 * Reflected server-side cross-site scripting query.
 * This query detects cases where user input is directly written to a web page.
 */

from WebPage wp, Expr userInputExpr, Expr outputExpr
where
  // Find expressions that take user input
  userInputExpr instanceof UserInputExpr and
  // Find expressions that output to the web page
  outputExpr instanceof WebPageOutputExpr and
  // Check if the user input expression is used in the output expression
  userInputExpr = outputExpr.getArgument(0)
select outputExpr, "Potential reflected XSS vulnerability detected."