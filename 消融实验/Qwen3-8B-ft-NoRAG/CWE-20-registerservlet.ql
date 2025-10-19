import py

from Call call, StringLiteral str, Variable var
where call.getMethodName() = "execute" and call.getArgument(0).getValue().contains(str) and var.getName().matches(".*input.*")
select call, "Potential SQL injection vulnerability"