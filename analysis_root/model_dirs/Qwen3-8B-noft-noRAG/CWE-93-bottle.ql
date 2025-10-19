import semmle.code.py.Python

/** @name CWE-93: Improper Neutralization of CRLF Sequences ('CRLF Injection') */
/**
 * Query to detect improper neutralization of CRLF sequences in HTTP headers,
 * which can lead to header injection vulnerabilities.
 */

// Define pattern for HTTP header injection through string concatenation
from PyStringConcatenation concat, PyCall setHeaderCall
where
  // Match calls to set header (common methods for setting headers)
  (setHeaderCall.getTarget().getQualifiedName() = "bottle.response.Response.headers" and
   setHeaderCall.getMethodName() = "__setitem__") or
  (setHeaderCall.getTarget().getQualifiedName() = "bottle.response.Response.set_header") or
  (setHeaderCall.getTarget().getQualifiedName() = "bottle.response.Response.set_cookie")

  // Ensure the concatenated string contains user input
  and concat is used in setHeaderCall.getArgs()

  // User input sources (common in web apps)
  and exists(PyVariableUse inputVar |
    inputVar is used in concat and
    (inputVar.getSource() instanceof PyFunctionCall and
     (inputVar.getSource().getMethod().getName() = "get" or
      inputVar.getSource().getMethod().getName() = "post")) and
    inputVar.getSource().getTarget().getQualifiedName() like "bottle.request.%")

select concat, "Potential CRLF injection detected in HTTP header setup."