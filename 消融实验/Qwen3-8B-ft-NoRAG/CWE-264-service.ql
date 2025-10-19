import python

from CallExpr call
where
  call.getCallee().getName() = "subprocess.run" or
  call.getCallee().getName() = "subprocess.call" or
  call.getCallee().getName() = "subprocess.check_output" or
  call.getCallee().getName() = "os.system"
  and (call.getArg(1).isStringLiteral() and call.getArg(1).getValue() = "shell=True") or
  (call.getArg(0).isStringLiteral() and call.getArg(0).getValue().matches(".*\\$.*"))
select call, "Unsafe shell command construction detected"