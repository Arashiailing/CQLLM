import python

/**
 * CWE-20: Improper Input Validation
 * Detects potential Server-Side Request Forgery (SSRF) vulnerabilities.
 */
from Call call, StringLiteral url
where call.getCallee().getName() = "requests.get" and
      call.getArgument(0) = url and
      not exists(Expr e |
        e instanceof BinaryExpr and
        e.getOperator() = "=" and
        e.getLeft() = url and
        e.getRight() instanceof StringLiteral and
        e.getRight().getValue().matches("https?://.*")
      )
select call, "Potential SSRF vulnerability detected. Validate the URL input before making the request."