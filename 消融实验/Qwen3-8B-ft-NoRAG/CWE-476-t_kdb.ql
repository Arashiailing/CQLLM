import python

from AssignExpr assign, CallExpr call, DotExpr dot
where assign.getVar().getName() = "var" and assign.getValue().isNull()
  and (call.getArg(0).getSymbol().getName() = "var" or dot.getBase().getName() = "var")
select assign, call, dot, "Potential NULL pointer dereference"