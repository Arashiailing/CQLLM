import python

/**
 * Reflected server-side cross-site scripting query
 */
from Expr userInput, Expr outputExpr
where
  // Check if the user input is written directly to the output
  outputExpr instanceof ConcatExpr and
  outputExpr.getAnOperand() = userInput and
  // Check if the output is part of a web response
  outputExpr.getAnAncestor() instanceof HttpResponse
select
  userInput, "This user input is directly written to the web page, which may lead to reflected XSS."