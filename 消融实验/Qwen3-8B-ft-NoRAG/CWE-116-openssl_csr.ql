import python

from Call call, StringLiteral str
where call.getTarget() = "open" and call.getArg(0) = str and str.getValue().matches(".*\.\./.*")
select call, "Potential path traversal vulnerability due to unvalidated input."