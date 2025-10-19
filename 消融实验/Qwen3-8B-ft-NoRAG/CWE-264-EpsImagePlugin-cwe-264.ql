import python

from Call call, StringLiteral str
where call.getTarget().getName() = "join" and (call.getArgument(0) = str or call.getArgument(1) = str) and str.getValue().contains("..")
select call, "Potential Path Injection via os.path.join with.. in path arguments"