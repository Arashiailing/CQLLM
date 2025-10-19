import python

/**
 * @name CWE-20: Improper Input Validation (SSRF)
 */
from CallExpr call, Argument arg, PyFunctionRef func
where func.getName() = "http.get" and call.getKind() = "Call"
  and arg.getValue().getType().getName() = "str"
  and exists(Var v | v.getInit().toString() = arg.getValue().toString())
select call.getLocation(), "Potential SSRF vulnerability due to unvalidated input in HTTP request."