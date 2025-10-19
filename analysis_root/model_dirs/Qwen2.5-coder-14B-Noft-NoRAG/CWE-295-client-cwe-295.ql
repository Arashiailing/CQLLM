import python

/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation. Making a request without certificate validation can allow man-in-the-middle attacks.
 * @id py/client-cwe-295
 */

from Call call, Argument arg
where call.getCallee().getName() = "get" and
      call.getCallee().getDeclaringType().getName() = "requests" and
      call.getCallee().getDeclaringType().getModule().getName() = "requests" and
      arg = call.getArgument(0) and
      not exists(Argument verifyArg |
        verifyArg = call.getArgument(1) and
        verifyArg.getValue() instanceof FalseLiteral
      )
select call, "This request does not validate the server's certificate, which can allow man-in-the-middle attacks."