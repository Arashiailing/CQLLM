import python

/**
 * A query to detect CWE-79: Reflected Cross-Site Scripting (XSS) vulnerabilities in Python web applications.
 * This query looks for cases where user input is directly written to the HTTP response without proper sanitization.
 */

from Expr userInput, Expr httpResponse
where httpResponse instanceof HttpResponse
  and userInput instanceof UserInput
  and httpResponse.getAChild*() = userInput
select httpResponse, "This HTTP response directly includes user input, which may lead to reflected XSS."