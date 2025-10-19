import python

from ArrayAccessExpr a
where a.getIndex().isNegative() or exists(CallExpr lenCall, a.getArray() = lenCall.getArgument() and lenCall.getFunction().getName() = "len" and a.getIndex() > lenCall)
select a