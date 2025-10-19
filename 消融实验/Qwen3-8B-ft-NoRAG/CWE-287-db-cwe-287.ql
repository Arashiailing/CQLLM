import python

from FunctionCall f, StringLiteral s
where f.getKind() = "call" and f.getDecl().getName() = "execute"
  and f.getArgument(0).getType().getName() = "str"
  and f.getArgument(0).getValue().matches(".*'(.*)'.*")
select f, "Potential SQL injection vulnerability in execute call."