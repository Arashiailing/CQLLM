import python

from FunctionCall call, StringLiteral str
where call.getTarget().getName() = "join" and call.getArgument(1) = str
select call, "Potential Path Injection due to unvalidated input in path construction."