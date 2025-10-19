import python

from Call call
where call.getCallee().getName() in ("subprocess.run", "subprocess.call", "os.system", "subprocess.Popen")
and call.getArgument(0).getType().isString()
and exists(Variable var |
  call.getArgument(0).getValue() contains var
  and var.isExternal()
)

select call, "Potential command injection vulnerability due to external string in command line."