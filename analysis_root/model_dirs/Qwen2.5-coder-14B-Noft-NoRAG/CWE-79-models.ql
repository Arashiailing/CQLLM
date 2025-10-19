import python

/**
 * A query to detect reflected server-side cross-site scripting (XSS) vulnerabilities.
 * This query looks for instances where user input is directly written to a web page.
 */

from DataFlow::Node source, DataFlow::Node sink
where source instanceof Expr and sink instanceof Expr
  and DataFlow::localFlow(source, sink)
  and sink instanceof CallExpr and sink.getCallee().getName() = "write"
  and exists(Expr userInput | userInput instanceof Expr and DataFlow::localFlow(userInput, source))
select sink, "Reflected XSS vulnerability detected: User input is directly written to the web page."