import python

from Call call
where call.getTarget().getName() in ["subprocess.run", "subprocess.call", "subprocess.check_call", "subprocess.check_output", "subprocess.Popen", "os.system"]
  and call.getArgument(0).isString() or call.getArgument(0).isVariable()
select call, "Potential command injection via command execution function with untrusted input."