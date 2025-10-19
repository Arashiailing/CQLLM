import python

from Call call
where call.getModule().getName() = "logging"
  and call.getFunction().getName() in ["info", "debug", "warning", "error", "critical"]
  and exists (StringLiteral sl where call.getArgument(0) = sl and sl.getValue() matches /password|secret|token|key|credentials/i)
select call, "Cleartext logging of sensitive information detected."