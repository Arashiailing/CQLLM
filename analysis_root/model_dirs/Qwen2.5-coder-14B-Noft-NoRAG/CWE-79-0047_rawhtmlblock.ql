import python

/**
 * This query detects reflected cross-site scripting (XSS) vulnerabilities
 * in Python web applications. It looks for instances where user input is
 * directly written to an HTML response without proper sanitization.
 */

from DataFlow::Node input, DataFlow::Node output
where DataFlow::localFlow(input, output) and
      output instanceof Expr and
      output.getEnclosingExpr() instanceof HtmlBlock and
      input instanceof UserInputExpr
select output, "Reflected XSS vulnerability: User input is directly written to an HTML block."