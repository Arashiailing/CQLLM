import python

/**
 * This query detects potential CWE-862: Reflected XSS vulnerabilities in Python code.
 * It looks for instances where user input is directly included in HTTP responses
 * without proper sanitization or encoding.
 */

from HttpRequest req, HttpResponse res, Expr userInput, Expr httpResponse
where req.getArgument("input") = userInput and
      httpResponse.getAChild() = userInput and
      httpResponse.getEnclosingStmt().getParent() instanceof HttpResponse
select httpResponse, "This HTTP response includes user input without proper sanitization, which may lead to Reflected XSS."