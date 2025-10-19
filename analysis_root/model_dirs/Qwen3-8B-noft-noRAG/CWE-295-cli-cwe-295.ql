import python

/**
 * @predicate hasInvalidCertificateValidation(expr)
 * @param expr The expression to check for improper certificate validation.
 */
predicate hasInvalidCertificateValidation(expr) {
  // Check for requests.get or requests.post calls with verify=False
  (expr instanceof CallExpr
    and (expr.getName() = "get" or expr.getName() = "post")
    and exists(ParamExpr p |
      p.isArgOf(expr)
      and p.getName() = "verify"
      and p.getValue() = false
    )
  )
}

from CallExpr c
where hasInvalidCertificateValidation(c)
select c, "Potential CWE-295: Improper certificate validation detected in request."