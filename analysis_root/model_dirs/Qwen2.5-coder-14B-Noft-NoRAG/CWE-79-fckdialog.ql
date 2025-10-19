import python

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/fckdialog
 */

from WebRequest request, Expr userInput, Expr outputExpr
where
  // Find a web request that writes user input directly to a web page
  request.getResponse().getAContent().getExpr() = outputExpr and
  // Check if the output expression contains user input
  userInput instanceof RequestParam and
  outputExpr instanceof HtmlOutput
select outputExpr, "This expression writes user input directly to an HTML output, which may lead to reflected XSS."