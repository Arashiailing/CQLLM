import python

/**
 * CWE-787: Out-of-bounds Write
 * This query detects potential out-of-bounds write vulnerabilities in Python code.
 */

from ArrayAccess arrayAccess, Index index
where arrayAccess.getIndex() = index and
      index.getType() instanceof IntType and
      not index.getValue().isConstant() and
      not index.getValue().isWithinBounds(arrayAccess.getArray().getType().getElementType())
select arrayAccess, "This array access may lead to an out-of-bounds write."