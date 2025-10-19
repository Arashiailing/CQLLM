import py

from CallExpr call
where call.callee.name in ("subprocess.check_output", "subprocess.run", "os.system", "subprocess.call", "subprocess.Popen") and
      call.args has NamedExpr named and named.name = "shell" and named.value = true
select call, "Potential command injection via shell=True with unvalidated input."