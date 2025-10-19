import python

/**
 * This query detects potential Reflected Cross-Site Scripting (XSS) vulnerabilities
 * in Python code, specifically when user input is directly written to a web page.
 */

from Call call, Expr user_input, Expr output
where
  // Check if the call is to a function that writes to a web page
  call.getCallee().getName() = "write" or call.getCallee().getName() = "render" and
  // Find the user input being passed to the function
  user_input = call.getArgument(0) and
  // Ensure the user input is not sanitized
  not exists(Sanitization sanitization | sanitization.getExpr() = user_input) and
  // Ensure the output is directly written to a web page
  output = call.getResult()
select output, "This call writes user input directly to a web page, which may lead to reflected XSS."