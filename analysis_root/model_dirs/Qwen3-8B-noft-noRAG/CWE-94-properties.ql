import python

from CallExpr call, Argument arg
where call.getFunction().getName() = "eval" 
   or call.getFunction().getName() = "exec"
   or call.getFunction().getName() = "__import__"
   and arg.getValue().getType().getName() = "str"
select call, "Potential code injection via dynamic code evaluation"