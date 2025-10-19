import py

from PyFunctionCall call, PyStringLiteral cmd, PyStringLiteral arg
where call.getName() = "subprocess.run" or call.getName() = "subprocess.call" or call.getName() = "os.system"
  and call.getArgument(0).getType().getName() = "str"
  and call.getArgument(0).getValue().contains(cmd)
  and exists(PyStringLiteral inputArg | call.getArgument(inputArg.getIndex()).getValue().contains("input()") or call.getArgument(inputArg.getIndex()).getValue().contains("request.args") or call.getArgument(inputArg.getIndex()).getValue().contains("request.form") or call.getArgument(inputArg.getIndex()).getValue().contains("os.environ"))
select call, "Potential CWE-20: Command Injection via unvalidated input"