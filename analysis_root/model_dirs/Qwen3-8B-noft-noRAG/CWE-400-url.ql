import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.scala.library.Library

from RegexPattern pattern, CallExpr call
where
  call.getTarget() = "re.compile"
  and call.getArgument(0).getValue().getAsString() = pattern.getValue()
  and pattern.getValue() matches /.*\W*\w+\W*\d+/  // 简化的危险模式匹配示例
select pattern, "Potential polynomial ReDoS vulnerability due to complex regex pattern."