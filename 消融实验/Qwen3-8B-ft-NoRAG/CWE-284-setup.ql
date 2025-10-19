import python

from CallExpr call
where call.getFunction().name in ("os.system", "subprocess.run", "subprocess.call", "subprocess.Popen")
select call, "Potential Command Injection vulnerability (CWE-284) detected via command execution function."