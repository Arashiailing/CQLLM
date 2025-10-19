import python

from Call call, StringLiteral str, Variable var
where call.getTarget().getName() = "run" and call.getArgument(0) = str + var and call.getArgument(1).getName() = "shell" and call.getArgument(1).getValue() = "True"
select call, "Unsafe shell command construction with string concatenation."