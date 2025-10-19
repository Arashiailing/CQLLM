import python
import semmle.code.cpp.dataflow.DataFlow

from CallExpr call, Argument arg
where
  call.getTarget().getName() = "decrypt" and
  arg.getPosition() = 0 and
  arg.getArgument() instanceof StringLiteral and
  call.getSource().getFile().getPath() = "gnupg.py"
select call, "Potential CWE-287: Improper authentication detected in decrypt operation"