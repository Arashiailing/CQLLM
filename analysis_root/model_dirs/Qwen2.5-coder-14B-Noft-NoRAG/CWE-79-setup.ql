import python

/**
 * This query detects reflected cross-site scripting (XSS) vulnerabilities
 * in Python web applications by looking for instances where user input is
 * directly written to the HTTP response without proper sanitization.
 */

from WebRequest req, WebResponse resp, Expr userInput, Expr httpResponse
where
  // Find user input in the request
  userInput instanceof RequestParameter and
  // Find the HTTP response object
  httpResponse instanceof HttpResponse and
  // Find the write operation to the HTTP response
  httpResponse.getMethod() = "write" and
  // Check if the user input is directly written to the HTTP response
  httpResponse.getArgument(0) = userInput
select httpResponse, "Reflected XSS vulnerability detected: User input is directly written to the HTTP response."