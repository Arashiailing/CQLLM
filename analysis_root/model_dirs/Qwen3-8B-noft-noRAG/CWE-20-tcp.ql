import python

/**
 * @name CWE-20: Improper Input Validation
 * @description Detects instances where inputs are used without proper validation.
 */
from CallExpr call
where call.getDecl().getName() in ("input", "raw_input", "sys.stdin.readline")
  and not exists (call.getArgs()[0].getType().isString())
select call, "Potential CWE-20: Improper Input Validation - Unvalidated input usage"