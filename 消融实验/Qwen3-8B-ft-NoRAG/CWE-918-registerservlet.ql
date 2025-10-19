import py

from Call call, Expr urlExpr
where call.getMethod().getName() in ["get", "post"] and call.getModule().getName() = "requests"
and urlExpr = call.getArgument(0)
and urlExpr.isStringLiteral() or urlExpr.isUserInput()
select call, "Potential SSRF vulnerability: user-controlled URL in request"