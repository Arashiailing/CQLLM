import py

from CallExpr call
where call.getCallee().getName() in ["subprocess.run", "os.system", "subprocess.call", "subprocess.Popen"]
select call, "Potential command injection via command execution function."