import python

/**
 * CWE-295: Improper Certificate Validation
 * Detects instances where a request is made without certificate validation.
 */
from Call call
where call.getCallee().getName() = "requests.get" or call.getCallee().getName() = "requests.post"
  and not call.getArgument(1).getQualifiedName() = "verify"
  and not call.getArgument(1).getQualifiedName() = "cert"
select call, "This request does not validate the server's certificate, which can lead to man-in-the-middle attacks."