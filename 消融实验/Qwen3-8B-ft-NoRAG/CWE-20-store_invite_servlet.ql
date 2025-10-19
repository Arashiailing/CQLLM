import python
import semmle.code.python.dataflow.DataFlow

from Call call, Argument arg, StringLiteral strLit
where call.getMethod().getName() = "system" and call.getDeclaringType().getName() = "os"
  and arg.getArgumentPosition() = 0
  and arg.getValue() = strLit
  and strLit.getStringValue().matches(".*user_input.*")
select call, "Potential command injection via os.system with unvalidated input."