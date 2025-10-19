import py
import semmle.code.cpp.dataflow.DataFlow

from MethodCall call, Argument arg
where call.getMethodName() = "print" or call.getMethodName() = "write"
  and arg.getArgumentNumber() = 0
  and arg.getExpression().toString() = "f-string"
  and arg.getExpression().toString().contains("{")
  and arg.getExpression().toString().contains("}")
select call, "Potential reflected XSS vulnerability: user input directly embedded in HTML output."