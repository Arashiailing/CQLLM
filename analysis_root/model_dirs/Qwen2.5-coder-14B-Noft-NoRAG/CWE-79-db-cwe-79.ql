import python

/**
 * A query to detect CWE-79: Reflected server-side cross-site scripting.
 */
from WebPage page, Expr userInput, Expr outputExpr
where
  // Find expressions that read user input.
  userInput instanceof UserInputExpr and
  // Find expressions that write to the web page.
  outputExpr instanceof WebPageOutputExpr and
  // Ensure the user input is directly written to the web page.
  userInput = outputExpr
select
  outputExpr,
  "Reflected server-side cross-site scripting vulnerability detected."