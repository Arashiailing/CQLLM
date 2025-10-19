import python

/**
 * This query detects instances where CSRF protection is disabled or weakened.
 * CWE-352: URL Redirector with Query Parameter
 */

class UrlRedirector {
  UrlRedirector() {
    exists(Method m, Expr urlExpr |
      m.getName() = "redirect" and
      m.getAParameter().getType().getName() = "str" and
      urlExpr instanceof BinaryExpr and
      urlExpr.getOperator() = "+" and
      urlExpr.getLeftOperand() instanceof StringLiteral and
      urlExpr.getRightOperand() = m.getAParameter().getAReference()
    )
  }
}

from UrlRedirector redirector
select redirector, "Potential CSRF vulnerability due to URL redirection with query parameter."