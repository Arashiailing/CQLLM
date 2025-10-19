import python

/**
 * This query detects reflected cross-site scripting (XSS) vulnerabilities
 * in Python web applications. It looks for cases where user input is directly
 * written to an HTTP response without proper sanitization.
 */

from HttpResponse httpResponse, Expr userInputExpr
where httpResponse.getBody().contains(userInputExpr)
select userInputExpr, "Reflected XSS vulnerability detected: User input is directly written to the HTTP response."