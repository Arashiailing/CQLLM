import python

from Call call, Argument arg
where call.getSelector().getName() in ["run", "call", "system"]
  and (call.getModule().getName() = "subprocess" or call.getModule().getName() = "os")
  and arg.getValue().getKind() = "string"
  and (call.getSelector().getName() = "run" and call.getArg(1).getValue().getKind() = "string" and call.getArg(1).getValue().getContents().contains("shell=True"))
  or (call.getSelector().getName() = "system" and call.getArg(0).getValue().getKind() = "string")
select call, "Potential command injection via command injection"