import python

from File file, Expr pathExpr
where pathExpr instanceof StrLiteral or pathExpr instanceof ConcatExpr
  and exists(FileAccess fa | fa.getFile() = file and fa.getPathExpr() = pathExpr)
select pathExpr, "This path expression is influenced by user input and may be vulnerable to path injection."