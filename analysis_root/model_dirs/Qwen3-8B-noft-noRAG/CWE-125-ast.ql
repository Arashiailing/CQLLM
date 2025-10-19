import python
import semmle.code.cpp.dataflow.DataFlow

from CallExpr call, StringLiteral str, NamedArgument arg
where call.getArgument(0).isStringLiteral() and call.getName().getName() = "open"
  and call.getArgument(0).getValue() = str.getValue()
  and str.getValue().matches(".*\\.\./.*")
select call, "Potential CWE-125 (Path Traversal) vulnerability detected: Unsanitized path in open call with.. component."