import python

from Call call
where call.getFunction().getName() in ["os.system", "subprocess.run", "subprocess.call", "subprocess.Popen"]
  and (call.getFunction().getName() = "os.system"
    or (call.getFunction().getName() = "subprocess.run" and call.getArgument("shell") = true)
    or (call.getFunction().getName() = "subprocess.call" and call.getArgument(0).getType().getName() = "str")
    or (call.getFunction().getName() = "subprocess.Popen" and call.getArgument(0).getType().getName() = "str"))
select call, "Potential command injection via command execution function"