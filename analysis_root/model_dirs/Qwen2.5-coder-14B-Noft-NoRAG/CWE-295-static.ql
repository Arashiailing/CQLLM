import python

/**
 * @name CWE-295: Improper Certificate Validation
 * @description Request without certificate validation.Making a request without certificate validation can allow man-in-the-middle attacks.
 * @id py/static
 */

from Call call, Argument arg
where call.getCallee().getName() = "requests.get" or call.getCallee().getName() = "requests.post"
  and not exists(Argument verifyArg | verifyArg.getCall() = call and verifyArg.getIndex() = 1 and verifyArg.getValue() instanceof Boolean and verifyArg.getValue().getValue() = true)
select call, "This request does not validate the server's certificate, which can lead to a man-in-the-middle attack."