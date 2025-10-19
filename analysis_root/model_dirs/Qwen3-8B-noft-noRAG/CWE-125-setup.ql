import python

from Call call, Argument arg, Expr container, Expression indexExpr
where call.getTarget().getName() = "__getitem__"
  and call.getArgument(0).getValue() = container
  and call.getArgument(1).getValue() = indexExpr
  and (indexExpr.isNegative() or indexExpr.ge(length(container)))
select indexExpr, "Potential out-of-bounds read"