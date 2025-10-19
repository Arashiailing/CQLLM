import python

/**
 * This query detects reflected server-side cross-site scripting (XSS) vulnerabilities.
 * It looks for instances where user input is directly written to a web page.
 */

from Expr userInput, Expr outputExpr
where userInput instanceof Call and
      outputExpr instanceof Call and
      userInput.getMethod().hasName("request.getParameter") and
      outputExpr.getMethod().hasName("response.getWriter().write")
select outputExpr, "This expression writes user input directly to the response, which may lead to reflected XSS."