import python

from List list, Expr indexExpr, Access access
where access.getBase() = list and access.getIndex() = indexExpr
select access, "Potential out-of-bounds read due to unverified index"