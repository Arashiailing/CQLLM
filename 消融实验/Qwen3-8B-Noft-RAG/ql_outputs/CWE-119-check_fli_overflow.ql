import python
import semmle.code.cpp.dataflow.DataFlow

from Call call, Argument arg, Expr expr
where call.getTarget().getName() = "getitem" and
      arg = call.getArgument(0) and
      expr = arg.getExpression() and
      expr.isNegative()
select expr, "Potential out-of-bounds array access due to negative index"