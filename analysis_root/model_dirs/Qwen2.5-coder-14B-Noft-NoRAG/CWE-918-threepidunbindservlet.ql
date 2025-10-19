import python

/**
 * CWE-918: Server-Side Request Forgery (SSRF)
 * Detects cases where a server makes a network request to a URL that is partially user-controlled.
 */

from HTTPRequest request, Expr urlExpr
where request.getURL() = urlExpr and
      urlExpr instanceof ConcatExpr or
      urlExpr instanceof BinaryExpr or
      urlExpr instanceof CallExpr
select urlExpr, "This URL expression is partially user-controlled, which may lead to Server-Side Request Forgery (SSRF)."