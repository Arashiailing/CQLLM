import python

/**
 * CWE-295: Improper Certificate Validation
 * Detects requests made without certificate validation in Python.
 */

from Call call, Argument arg
where call.getCallee().getName() = "get" and
      call.getCallee().getDeclaringType().getName() = "requests.Session" and
      arg = call.getArgument(0) and
      not exists(Argument verifyArg | verifyArg = call.getArgument(1) and
                  verifyArg.getValue() instanceof BoolLiteral and
                  verifyArg.getValue().getValue() = true)
select call, "This request does not validate the server's certificate, which can allow man-in-the-middle attacks."