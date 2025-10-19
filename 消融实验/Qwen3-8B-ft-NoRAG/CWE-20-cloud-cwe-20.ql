import python

from FunctionCall call, Argument arg, Literal lit
where call.name = "os.system" and arg.position = 0 and arg.value = lit
  and lit.value.toString() =~ ".*\$\{.*\}.*" or lit.value.toString() =~ ".*;.*" or lit.value.toString() =~ ".*&&.*"
select call, "Potential command injection vulnerability due to unvalidated input in os.system call."