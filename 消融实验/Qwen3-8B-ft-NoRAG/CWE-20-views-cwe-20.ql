import python

from Call call, Argument arg
where call.getMethod().getName() = "execute"
  and arg.getValue().getType().getName() = "str"
  and arg.getValue().getExpression().getKind() = "BinaryOp"
  and arg.getValue().getExpression().getOperator() = "+"
select call, "Potential SQL injection due to string concatenation in execute call."