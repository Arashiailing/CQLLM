import python

from Call call, StringLiteral strLit, Variable var
where call.getMethodName() = "open"
  and call.getArgument(0) = strLit
  and strLit.getValue() contains var.getName()
select call, "Potential Path Injection due to unvalidated user input in file path."