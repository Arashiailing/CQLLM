import python

from Call input_call, Expression input_expr, ForLoop for_loop, Expression buffer_expr
where input_call.getTarget() = python.InputFunction()
  and input_expr = input_call.getArg(0)
  and for_loop.getIter() = python.RangeExpr(python.LengthExpr(input_expr), python.IntegerLiteral(0))
  and for_loop.getBody() has AssignmentStmt(
    with LHS = python.SubscriptExpr(buffer_expr, python.IntegerLiteral(i)),
    RHS = python.SubscriptExpr(input_expr, python.IntegerLiteral(i))
  )
  and buffer_expr is a python.ListLiteral with size 100
select buffer_expr, "Potential CWE-120: Buffer Copy without Checking Size of Input"