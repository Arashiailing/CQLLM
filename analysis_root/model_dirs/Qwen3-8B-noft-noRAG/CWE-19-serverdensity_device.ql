import python

from Call call
where call.getFunction().getName() in (
  "os.system",
  "subprocess.run",
  "subprocess.call",
  "subprocess.check_output",
  "commands.getoutput"
)
select call, "Potential command injection via dangerous function call."