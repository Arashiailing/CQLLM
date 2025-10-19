import python
import semmle.code.cpp.dataflow.DataFlow

from CallExpr call, Arg arg, LiteralStringLiteral str
where call.getMethodName() = "system" and
      arg.getArgumentPosition() = 0 and
      arg.getValue().getUnderlyingValue() = str and
      str.getStringValue() contains "$"
select call, "Potential command injection via os.system with unvalidated input"