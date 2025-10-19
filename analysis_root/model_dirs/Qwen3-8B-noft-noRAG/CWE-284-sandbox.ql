import python

/**
 * @name CWE-284: Improper Access Control
 * @description Detects improper access control via command injection vulnerabilities.
 * @id py/sandbox
 */
from MethodCall mc, StringLiteral sl
where mc.getMethodName() = "subprocess" and mc.getArgumentExpressions()[0] = sl
  and sl.getValue() = "shell"
select mc, "Potential CWE-284: Command injection via subprocess with shell=True."