import python

from ListAccessExpr access, Expr index, List list
where access.getIndex().getExpression() = index
  and list = access.getList()
  and (index.isIntLiteral() and index.getIntValue() < 0 or index.isIntLiteral() and index.getIntValue() >= list.getLength())
select access, "Potential CWE-119: Out-of-bounds list access detected"