import py

from Call call
where
  call.getModule().getName() = "requests" and
  (call.getFunction().getName() = "get" or call.getFunction().getName() = "post" or call.getFunction().getName() = "request") and
  call.hasArgument("verify") and
  call.getArgument("verify").getValue() == false
select call, "Potential CWE-295: Improper Certificate Validation detected in request without certificate validation."