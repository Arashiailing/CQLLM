import python
import semmle.code.java.ExpressionHandling

from Call call, StringLiteral stringLit, Argument arg
where 
  call.getTarget().getName() = "open" and
  arg = call.getArgument(0) and
  arg.hasValue(stringLit) and
  stringLit.getValue().matches(".*\\\\.\$$|..|~")
select call, "Potential Path Injection via unvalidated file path"