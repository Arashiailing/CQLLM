import python

/**
 * CWE-264: Unchecked Permissions
 * Detects cases where permissions are not checked before performing sensitive operations.
 */

from FunctionCall call, Argument arg
where call.getCallee().getName() = "performSensitiveOperation"
  and not exists(call.getAnArgument() as Argument a | a.getValue() instanceof FunctionCall and a.getFunction().getName() = "checkPermissions")
select call, "Sensitive operation performed without checking permissions."