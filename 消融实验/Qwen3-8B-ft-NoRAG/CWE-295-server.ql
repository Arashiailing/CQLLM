import semmle.python.security.security

from PyCall call
where call.getTarget() = "requests.get" or call.getTarget() = "requests.post"
  and call.getArgument("verify") = false
select call, "This request does not validate the certificate."