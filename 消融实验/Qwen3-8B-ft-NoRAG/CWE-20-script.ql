import python

from Call call
where call.getCallee().getName() in ["os.system", "subprocess.run", "subprocess.call", "subprocess.Popen"]
  and call.getArgument(0).getType().isString()
select call, "Potential command injection vulnerability due to unvalidated input."