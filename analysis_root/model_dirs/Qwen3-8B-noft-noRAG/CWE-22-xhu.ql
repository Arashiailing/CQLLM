import python

from Call call, Variable var, StringLiteral lit
where call.getTarget().getQualifiedName() = "builtins.open"
   and call.getNumArgs() > 0
   and call.getArg(0) = var
   and var.isAssignedFromUserInput()
select call, "Potential path injection vulnerability due to uncontrolled data in file path."