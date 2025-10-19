import py

from Call call, BinaryOp op
where call.getTarget().getName() = "open" and
      call.getArgument(0) = op and
      op.getOperator() = "+" and
      op.getLeftOperand() is StringLiteral and
      op.getRightOperand() is Variable
select op, "Uncontrolled data used in path expression"