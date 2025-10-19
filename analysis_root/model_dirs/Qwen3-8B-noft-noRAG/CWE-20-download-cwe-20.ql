import python

/**
 * @name CWE-20: Improper Input Validation - Path Injection
 */
from MethodCall call, StringLiteralConcatenation concats, Assignment assign
where call.getMethodName() = "open" or call.getMethodName() = "os_open" or call.getMethodName() = "subprocess_check_output"
  and assign.getTarget().getName().matches(".*input.*|.*user.*|.*param.*")
  and assign.getAssignedValue() = concats
  and concats.getExpressions()[0].isStringLiteral() or concats.getExpressions()[1].isStringLiteral()
select assign.getTarget(), "Potential Path Injection via untrusted input in path construction."