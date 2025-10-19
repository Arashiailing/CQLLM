import python

/**
 * CWE-295: Improper Certificate Validation
 * This query detects cases where a request is made without proper certificate validation.
 */

from Call call, Argument arg
where call.getCallee().getName() = "requests.get" and
      arg = call.getArgument(0) and
      not exists(Argument certArg | certArg = call.getArgument(1) and
                  (certArg.getValue().getValue() instanceof String and
                   certArg.getValue().getValue() = "verify") and
                  certArg.getNextArgument() and
                  certArg.getNextArgument().getValue() instanceof Boolean and
                  certArg.getNextArgument().getValue().getValue() = true)
select call, "This request does not validate the server's certificate, which may allow man-in-the-middle attacks."