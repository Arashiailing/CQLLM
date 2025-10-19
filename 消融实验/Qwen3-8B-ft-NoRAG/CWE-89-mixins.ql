import python

from Call call, StringLiteral strLit, Variable var
where (call.getTarget() = strLit and call.getArgument(0) = var) or
      (call.getTarget() = strLit.format(var))
select call, "Potential SQL injection via string concatenation or formatting"