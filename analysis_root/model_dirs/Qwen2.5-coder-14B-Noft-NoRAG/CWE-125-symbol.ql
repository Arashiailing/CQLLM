import python

/**
 * This query detects potential CWE-125: Out-of-bounds Read vulnerabilities.
 * It looks for cases where a buffer is accessed out of its bounds.
 */
from ArrayAccess arrAccess, Expr arrayExpr, Expr indexExpr
where arrayExpr.getType() instanceof ArrayType and
      indexExpr.getType() instanceof IntType and
      not (indexExpr instanceof BinaryExpr and indexExpr.getOperator() = "+")
select arrAccess, "Potential out-of-bounds read detected."