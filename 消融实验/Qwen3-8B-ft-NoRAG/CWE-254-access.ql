import python

from Call call
where call.getCallee().getName() in ["os.system", "subprocess.call", "subprocess.run", "subprocess.Popen"]
select call, "Potential Code Injection via command execution"