import python
import semmle.code.scalacross.Common

from MethodCall mc, Argument arg, Expression expr
where 
  mc.getMethod().getName() = "__getitem__" and
  arg.getKind() = ArgKind.ARGUMENT and
  expr = arg.getValue() and
  (expr.isIntegerLiteral() and 
   (expr.getIntegerValue() < 0 or expr.getIntegerValue() >= mc.getReceiver().getLength()) or
   expr.isName() and 
   expr.getName() = "len" and 
   expr.getParentExpr().isName() and 
   expr.getParentExpr().getName() = "list")
select expr, "Potential out-of-bounds read detected"