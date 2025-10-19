import python

from Call call, StringLiteral strLit
where 
  call.getTarget().getModule().getName() = "python" and
  call.getMethodName() = "print" and
  exists (StringConcatenation conc where conc.getOperator() = "+" and
          call.getArgument(0) = conc and
          conc.getRightOperand() = strLit and
          strLit.getValue().startsWith("<") and
          strLit.getValue().contains(">"))
select call, "Potential reflected XSS vulnerability: User input is directly output to HTML without escaping"