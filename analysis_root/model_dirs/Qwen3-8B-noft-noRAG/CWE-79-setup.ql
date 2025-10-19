import python
import semmle.code.cpp.dataflow.DataFlow

from MethodCall call, Argument arg
where 
  call.getMethodName() = "write" and 
  arg.getArgumentPosition() = 0 and 
  exists (StringLiteral sl, CallExpr ce |
    ce.getCalls().getFunction() = "str" and 
    ce.getArguments().get(0).getValue() = sl.getStringValue() and 
    sl.getValue() like "%{{%") or 
    call.getDefinition().getFile().getName() = "app.py" and 
    call.getDefinition().getSource().contains("input()")
select call, "Potential reflected XSS: User input is directly written to response without proper escaping."