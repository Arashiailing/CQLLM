import python

/**
 * This query detects CWE-295: Improper Certificate Validation
 * by identifying HTTP requests made without certificate validation.
 */

from Call call, Argument arg
where call.getCallee().getName() = "requests.get" or call.getCallee().getName() = "requests.post"
  and arg = call.getArgument(0)
  and not exists(Argument certArg | certArg = call.getArgument(1) and certArg.getValue() instanceof String and certArg.getValue().asString() = "verify=True")
select call, "This request does not validate the server's certificate, which can allow man-in-the-middle attacks."