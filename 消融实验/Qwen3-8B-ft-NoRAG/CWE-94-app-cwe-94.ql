import python

from CallExpr call, StringLiteral str
where call.getArgument(0) = str
  and (call.getFunction().getName() = "eval" or call.getFunction().getName() = "exec")
select call, "Potential code injection via direct execution of user-controlled string"